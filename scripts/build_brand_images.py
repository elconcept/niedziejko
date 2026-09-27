#!/usr/bin/env python3
"""Brand images: real letterhead lockup composited onto the photo crops.

Requires ImageMagick 7 (`magick`) and Adobe Garamond Pro (the face used on the
firm's stationery). Run from repo root: python scripts/build_brand_images.py
"""
import os, subprocess, tempfile

FONT = os.environ.get("LOCKUP_FONT", "C:/Windows/Fonts/AGaramondPro-Regular.otf")
WEB = "assets/images/web"
TMP = tempfile.mkdtemp()


def run(*a):
    subprocess.run(["magick", *a], check=True)


def width(path):
    return int(subprocess.run(["magick", "identify", "-format", "%w", path],
                              capture_output=True, text=True, check=True).stdout)


def lockup(out, scale, ink):
    """ADWOKAT / rule / KAMIL NIEDZIEJKO - as on the firm's letterhead."""
    l1, l2, rule = (os.path.join(TMP, n) for n in ("l1.png", "l2.png", "rule.png"))
    run("-background", "none", "-fill", ink, "-font", FONT, "-pointsize", str(34 * scale),
        "-kerning", str(9 * scale), "label:ADWOKAT", "+repage", l1)
    run("-background", "none", "-fill", ink, "-font", FONT, "-pointsize", str(40 * scale),
        "-kerning", str(7 * scale), "label:KAMIL NIEDZIEJKO", "+repage", l2)
    run("-size", f"{int(width(l2) * 0.66)}x{max(1, 2 * scale)}", "xc:" + ink, rule)
    run("-background", "none", l1, "-size", f"1x{6 * scale}", "xc:none", rule,
        "-size", f"1x{14 * scale}", "xc:none", l2, "-gravity", "center", "-append", "+repage", out)


def place(page_w, page_h, rel_w, cx, cy, ink, out):
    """Lockup on a transparent page canvas, centred at (cx, cy) as page fractions."""
    lk = os.path.join(TMP, "lk.png")
    lockup(lk, 3, ink)
    run(lk, "-resize", f"{int(page_w * rel_w)}x", "+repage", lk)
    run("-size", f"{page_w}x{page_h}", "xc:none", lk, "-gravity", "center",
        "-geometry", f"{int(page_w * cx) - page_w // 2:+d}{int(page_h * cy) - page_h // 2:+d}",
        "-composite", "+repage", out)


def distort(page, quad, k, size, blur, out):
    """Map page corners (TL, TR, BL, BR) onto quad given in source-photo pixels, scaled by k."""
    w, h = (int(v) for v in subprocess.run(["magick", "identify", "-format", "%w %h", page],
                                           capture_output=True, text=True, check=True).stdout.split())
    src = [(0, 0), (w, 0), (0, h), (w, h)]
    pts = " ".join(f"{s[0]},{s[1]} {d[0] * k:.1f},{d[1] * k:.1f}" for s, d in zip(src, quad))
    run(page, "-virtual-pixel", "transparent", "-define", f"distort:viewport={size}+0+0",
        "-distort", "Perspective", pts, "+repage", "-blur", f"0x{blur}", out)


def encode(src, name, widths):
    for i, w in enumerate(widths):
        suffix = "" if i == 0 else f"-{w}"
        run(src, "-resize", f"{w}x", "-strip", "-interlace", "Plane", "-quality", "84",
            f"{WEB}/{name}{suffix}.jpg")
        run(src, "-resize", f"{w}x", "-strip", "-quality", "80", f"{WEB}/{name}{suffix}.webp")


def upscale(src, k, out):
    run(src, "-filter", "Lanczos", "-resize", f"{int(k * 100)}%", "-unsharp", "0x0.8+0.6+0.02", out)


def practice():
    """Printed letterhead on the top sheet of the paper stack (practice-3 crop, 555x1000)."""
    k = 2.0
    base = os.path.join(TMP, "p_base.png"); upscale(f"{WEB}/practice-3.jpg", k, base)
    page = os.path.join(TMP, "p_page.png"); place(1728, 2444, 0.40, 0.5, 0.104, "#27211c", page)
    ink = os.path.join(TMP, "p_ink.png")
    distort(page, [(88, 298), (500, 171), (505, 745), (917, 618)], k, f"{int(555 * k)}x{int(1000 * k)}", 0.7, ink)
    out = os.path.join(TMP, "p_out.png")
    run(base, "(", ink, "-channel", "A", "-evaluate", "multiply", "0.82", "+channel", ")",
        "-compose", "over", "-composite", out)
    encode(out, "letterhead-paper", [1000, 640])


def folder():
    """Letterpress lockup on the kraft folder (hero-9 crop, 737x1024)."""
    k = 1.6
    base = os.path.join(TMP, "f_base.png"); upscale(f"{WEB}/hero-9.jpg", k, base)
    page = os.path.join(TMP, "f_page.png"); place(2000, 1600, 0.31, 0.28, 0.56, "#1a1410", page)
    ink = os.path.join(TMP, "f_ink.png")
    distort(page, [(355, 561), (772, 634), (85, 665), (520, 748)], k, f"{int(737 * k)}x{int(1024 * k)}", 0.5, ink)
    hi = os.path.join(TMP, "f_hi.png")
    run(ink, "-fill", "#f3e9da", "-colorize", "100", "-channel", "A", "-evaluate", "multiply", "0.35",
        "+channel", "-roll", "+0+2", hi)
    run(ink, "-channel", "A", "-evaluate", "multiply", "0.74", "+channel", ink)
    out = os.path.join(TMP, "f_out.png")
    run(base, hi, "-compose", "over", "-composite", ink, "-compose", "over", "-composite", out)
    encode(out, "desk-folder", [1100, 720])


def card():
    """Business card + letter on the desk (contact-6 crop, 768x1024) - hero image."""
    out = os.path.join(TMP, "c_out.png"); upscale(f"{WEB}/contact-6.jpg", 1.5, out)
    encode(out, "hero-card", [1152, 760])


def signature():
    """Signature in violet ink (as signed on the letters) and in paper tone for dark backgrounds."""
    # Source scan has a smudge under the descenders (x~215-310, y>150): taper the
    # descenders out there so they read as pen lift; keep the long lead-in stroke.
    fade = os.path.join(TMP, "fade.png")
    run("-size", "489x185", "xc:white", "(", "-size", "100x28", "gradient:white-black", ")",
        "-geometry", "+212+126", "-composite", "-fill", "black", "-draw", "rectangle 212,154 312,185",
        "+repage", fade)
    for name, colour in (("signature-ink", "#4b2d6e"), ("signature-paper", "#efe7da")):
        run(f"{WEB}/signature.png", "-background", "white", "-flatten", "+repage",
            "-colorspace", "gray", "-negate", "-level", "8%,70%", fade, "-fx", "u*v",
            "-alpha", "copy", "-fill", colour, "-colorize", "100", "-trim", "+repage", f"{WEB}/{name}.png")


if __name__ == "__main__":
    practice(); folder(); card(); signature(); og_image()
    print("brand images: OK")


def og_image():
    """1200x630 social card: letterhead lockup on paper + the business-card photo."""
    lk = os.path.join(TMP, "og_lk.png"); lockup(lk, 3, "#25211d")
    run(lk, "-resize", "440x", lk)
    photo = os.path.join(TMP, "og_ph.png")
    run(f"{WEB}/hero-card.jpg", "-resize", "560x", "-gravity", "south", "-crop", "560x630+0+0", "+repage", photo)
    run("-size", "1200x630", "xc:#f7f4ef", lk, "-gravity", "west", "-geometry", "+100-40", "-composite",
        "-font", FONT.replace("Regular", "Italic"), "-fill", "#6b6258", "-pointsize", "30",
        "-gravity", "west", "-annotate", "+100+80", "Kancelaria adwokacka · Kraków",
        photo, "-gravity", "east", "-composite", "-strip", "-quality", "86", "og-image.jpg")
