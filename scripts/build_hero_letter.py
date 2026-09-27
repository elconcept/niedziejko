#!/usr/bin/env python3
"""Hero image: the letter on the desk rewritten as a real letter on Kamil's letterhead.

The generated photo carried pseudo-text with warped lines. It is removed (paper light
re-estimated, grain re-synthesised to the statistics of the surrounding paper) and a
justified letter is laid onto the sheet in perspective: letterhead, handwritten
salutation and signature (scanned violet ink), typed body - as in Kamil's letters.

Needs Pillow + numpy and Adobe Garamond Pro.
Run from repo root: <venv>/python scripts/build_hero_letter.py
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

WEB = "assets/images/web"
FONT = os.environ.get("LOCKUP_FONT", "C:/Windows/Fonts/AGaramondPro-Regular.otf")
K = 1.5                                   # upscale of the 768x1024 source crop
INK = (38, 33, 29)

# geometry in source-crop pixels (contact-6.jpg, 768x1024)
PAGE = [(-5, 689), (302.5, 642.5), (660, 876), (222.5, 986)]        # TL, TR, BR, BL of the top sheet
TEXT_AREA = [(-5, 689), (302.5, 642.5), (550, 803), (165, 886), (145, 885)]  # sheet above the card
GRAIN_PATCH = (352, 907, 460, 925)       # clean paper on the business card, below its text

DATE = "Kraków, dnia 14 września 2026 r."
BODY = [
    "w odpowiedzi na Pana zapytanie uprzejmie informuję, że kancelaria podejmie się "
    "prowadzenia sprawy. Przed pierwszym spotkaniem proszę o przygotowanie posiadanych "
    "dokumentów, w szczególności korespondencji z drugą stroną oraz pism otrzymanych z sądu.",
    "Podczas spotkania omówimy stan faktyczny, możliwe kierunki działania oraz związane "
    "z nimi ryzyka i koszty. Po analizie dokumentów przedstawię pisemną rekomendację "
    "dalszych kroków.",
    "Proszę o kontakt telefoniczny lub mailowy w celu ustalenia dogodnego terminu spotkania.",
]


def scaled(pts):
    return [(x * K, y * K) for x, y in pts]


def homography(src, dst):
    """3x3 matrix mapping src points to dst points (4 pairs)."""
    a = []
    for (x, y), (u, v) in zip(src, dst):
        a.append([x, y, 1, 0, 0, 0, -u * x, -u * y, -u])
        a.append([0, 0, 0, x, y, 1, -v * x, -v * y, -v])
    _, _, vt = np.linalg.svd(np.asarray(a, float))
    h = vt[-1].reshape(3, 3)
    return h / h[2, 2]


def polygon_mask(size, pts, erode, feather):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).polygon(pts, fill=255)
    if erode:
        m = m.filter(ImageFilter.MinFilter(erode * 2 + 1))
    return m.filter(ImageFilter.GaussianBlur(feather))


def clean_paper(img, mask):
    """Remove printed pseudo-text: estimate paper light robustly, then re-add grain."""
    arr = np.asarray(img, float)
    x0, y0, x1, y1 = (int(v * K) for v in GRAIN_PATCH)
    patch = arr[y0:y1, x0:x1]
    patch_hp = patch - np.asarray(Image.fromarray(patch.astype(np.uint8)).filter(ImageFilter.GaussianBlur(4)), float)
    grain_std = patch_hp.reshape(-1, 3).std(axis=0)

    # light: median at 1/8 scale ignores thin dark strokes, then smooth back up
    small = img.resize((img.width // 8, img.height // 8), Image.BILINEAR).filter(ImageFilter.MaxFilter(3))
    small = small.filter(ImageFilter.MedianFilter(5)).filter(ImageFilter.GaussianBlur(1.2))
    light = np.asarray(small.resize(img.size, Image.BICUBIC), float)

    rng = np.random.default_rng(7)
    noise = rng.normal(0, 1, arr.shape[:2])
    noise = np.asarray(Image.fromarray(((noise * 40) + 128).clip(0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.7)), float)
    noise = (noise - noise.mean()) / noise.std()
    grain = noise[..., None] * grain_std[None, None, :]
    cleaned = light + grain

    m = np.asarray(mask, float)[..., None] / 255
    return Image.fromarray((arr * (1 - m) + cleaned * m).clip(0, 255).astype(np.uint8)), grain_std


def justified(draw, text, font, x, y, width, lead, indent):
    words = text.split()
    lines, cur = [], []
    for w in words:
        trial = cur + [w]
        avail = width - (indent if not lines else 0)
        if cur and draw.textlength(" ".join(trial), font=font) > avail:
            lines.append(cur); cur = [w]
        else:
            cur = trial
    lines.append(cur)
    for i, ln in enumerate(lines):
        lx = x + (indent if i == 0 else 0)
        avail = width - (indent if i == 0 else 0)
        if i == len(lines) - 1 or len(ln) == 1:
            draw.text((lx, y), " ".join(ln), font=font, fill=255)
        else:
            gap = (avail - sum(draw.textlength(w, font=font) for w in ln)) / (len(ln) - 1)
            cx = lx
            for w in ln:
                draw.text((cx, y), w, font=font, fill=255)
                cx += draw.textlength(w, font=font) + gap
        y += lead
    return y


def lockup(draw, cx, y, scale):
    f1 = ImageFont.truetype(FONT, int(34 * scale))
    f2 = ImageFont.truetype(FONT, int(44 * scale))

    def spaced(text, font, track, y):
        w = sum(draw.textlength(c, font=font) for c in text) + track * (len(text) - 1)
        x = cx - w / 2
        for c in text:
            draw.text((x, y), c, font=font, fill=255)
            x += draw.textlength(c, font=font) + track
        return w
    spaced("ADWOKAT", f1, 12 * scale, y)
    rule_y = y + 48 * scale
    w2 = draw.textlength("KAMIL NIEDZIEJKO", font=f2) + 9 * scale * 15
    draw.rectangle([cx - w2 * 0.33, rule_y, cx + w2 * 0.33, rule_y + max(2, 2 * scale)], fill=255)
    spaced("KAMIL NIEDZIEJKO", f2, 9 * scale, rule_y + 14 * scale)


def letter_page(pw, ph):
    """Returns (typed-ink alpha, handwriting RGBA) for the page."""
    typed = Image.new("L", (pw, ph), 0)
    d = ImageDraw.Draw(typed)
    margin = int(pw * 0.12)
    lockup(d, pw / 2, int(ph * 0.055), pw / 1400)
    body_font = ImageFont.truetype(FONT, int(pw * 0.027))
    lead = int(pw * 0.027 * 1.42)
    y = int(ph * 0.15)
    d.text((pw - margin, y), DATE, font=body_font, fill=255, anchor="ra")

    hand = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    sal = Image.open(f"{WEB}/salutation-ink.png")
    sw = int(pw * 0.36)                                # oversized, as Kamil writes it
    sal = sal.resize((sw, int(sal.height * sw / sal.width)), Image.LANCZOS)
    hand.alpha_composite(sal, (margin - int(pw * 0.03), y + int(lead * 0.5)))

    y += int(lead * 0.5) + int(sal.height * 1.0) + int(lead * 0.25)
    for para in BODY:
        y = justified(d, para, body_font, margin, y, pw - 2 * margin, lead, int(pw * 0.06))
    y += int(lead * 0.1)
    d.text((pw - margin - int(pw * 0.08), y), "z poważaniem", font=body_font, fill=255, anchor="ra")
    sig = Image.open(f"{WEB}/signature-ink.png")
    gw = int(pw * 0.44)
    sig = sig.resize((gw, int(sig.height * gw / sig.width)), Image.LANCZOS)
    hand.alpha_composite(sig, (pw - margin - gw - int(pw * 0.02), y - int(lead * 0.2)))
    d.text((pw - margin - int(pw * 0.03), y + int(sig.height * 0.74)), "Adwokat Kamil Niedziejko",
           font=body_font, fill=255, anchor="ra")
    return typed, hand


def main():
    src = Image.open(f"{WEB}/contact-6.jpg").convert("RGB")
    base = src.resize((int(src.width * K), int(src.height * K)), Image.LANCZOS)
    base = base.filter(ImageFilter.UnsharpMask(radius=1, percent=45, threshold=2))
    area = polygon_mask(base.size, scaled(TEXT_AREA), 6, 3)
    base, grain_std = clean_paper(base, area)

    pw, ph = 1400, 1980
    typed, hand = letter_page(pw, ph)
    # soften like offset print, then warp page -> photo
    typed = typed.filter(ImageFilter.GaussianBlur(0.9))
    h = homography(scaled(PAGE), [(0, 0), (pw, 0), (pw, ph), (0, ph)])  # photo -> page
    coeffs = (h / h[2, 2]).flatten()[:8]
    warp = lambda im: im.transform(base.size, Image.PERSPECTIVE, tuple(coeffs), Image.BICUBIC)
    typed_w = np.asarray(warp(typed), float) / 255
    hand_w = np.asarray(warp(hand.filter(ImageFilter.GaussianBlur(0.8))), float)
    clip = np.asarray(area, float) / 255

    arr = np.asarray(base, float)
    rng = np.random.default_rng(11)
    uneven = 1 - 0.12 * np.clip(rng.normal(0, 1, clip.shape), -2, 2)      # ink take-up on paper fibre
    a = (typed_w * 0.95 * uneven * clip)[..., None]
    ink = np.asarray(INK, float)[None, None, :]
    arr = arr * (1 - a) + (arr * ink / 255) * a                           # multiply blend: grain shows through
    ha = (hand_w[..., 3] / 255 * clip * 0.92)[..., None]
    arr = arr * (1 - ha) + (arr * hand_w[..., :3] / 255) * ha
    out = Image.fromarray(arr.clip(0, 255).astype(np.uint8))

    for w, suffix in ((1152, ""), (760, "-760")):
        im = out.resize((w, int(out.height * w / out.width)), Image.LANCZOS)
        im.save(f"{WEB}/hero-letter{suffix}.jpg", quality=86, optimize=True, progressive=True)
        im.save(f"{WEB}/hero-letter{suffix}.webp", quality=82, method=6)
    print("hero letter: OK, grain std", grain_std.round(2))


if __name__ == "__main__":
    main()
