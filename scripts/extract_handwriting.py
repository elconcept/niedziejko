#!/usr/bin/env python3
"""Cut Kamil's handwriting (salutation, signature) out of a scanned letter as ink PNGs.

The scan is confidential and NOT stored in the repo; only the cut-outs are.
Ink membership comes from colour (purple chroma, hysteresis-grown on a softened image),
stroke shape from luminance - this keeps thin strokes whole. Crop boxes and the
print-crossing band are for the 1399x2000 scan used in 2026-09.
Usage: <venv>/python scripts/extract_handwriting.py path/to/scan.webp
"""
import sys
from PIL import Image, ImageFilter
import numpy as np
img = Image.open(sys.argv[1]).convert("RGB")
full = np.asarray(img, np.float32)
soft = np.asarray(img.filter(ImageFilter.GaussianBlur(1.2)), np.float32)
lum = full.mean(axis=2)
chroma = (soft[..., 0] + soft[..., 2]) / 2 - soft[..., 1]      # purple: R and B above G

def grow(seed, allowed, n):
    m = Image.fromarray((seed * 255).astype(np.uint8))
    for _ in range(n):
        m = m.filter(ImageFilter.MaxFilter(3))
        a = (np.asarray(m) > 0) & allowed
        m = Image.fromarray((a * 255).astype(np.uint8))
    return np.asarray(m) > 0

strong = chroma > 14
weak = chroma > 3.5
member = grow(strong, weak, 25)
# one more pixel of slack so stroke edges (low chroma, anti-aliased) are kept
member = np.asarray(Image.fromarray((member * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))) > 0

paper = np.percentile(lum, 90)
dark = np.clip((paper - lum - 6) / 85, 0, 1)
# printed line "Adwokat Kamil Niedziejko" under the signature: black print is not ink
band = np.zeros_like(member); band[1492:1530, 960:1260] = True
# (print band handled below by row interpolation)
alpha = dark * member
# close pin-holes along the stroke (compression speckle, crossings with print)
a8 = Image.fromarray((alpha * 255).astype(np.uint8))
closed = np.asarray(a8.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.MinFilter(3)), np.float32) / 255
alpha = np.maximum(alpha, closed * member)
alpha = np.clip(alpha, 0, 1) ** 0.75
# where the descenders cross the printed name the scan is smeared/broken: rebuild each
# stroke across the print band by interpolating its position between clean rows
x0, x1, top, bot = 940, 1120, 1494, 1528

def runs(row):
    on = row > 0.35
    out, start = [], None
    for i, v in enumerate(on):
        if v and start is None: start = i
        if not v and start is not None: out.append((start, i)); start = None
    if start is not None: out.append((start, len(on)))
    return [r for r in out if r[1] - r[0] >= 2]

rt, rb = runs(alpha[top, x0:x1]), runs(alpha[bot, x0:x1])
print("strokes top/bottom", rt, rb)
alpha[top + 1:bot, x0:x1] = 0
for (a0, a1), (b0, b1) in zip(rt, rb):
    for y in range(top + 1, bot):
        t = (y - top) / (bot - top)
        c = (1 - t) * (a0 + a1) / 2 + t * (b0 + b1) / 2
        w = (1 - t) * (a1 - a0) + t * (b1 - b0)
        xs = np.arange(x1 - x0)
        prof = np.clip(1 - np.abs(xs - c) / (w / 2 + 0.8), 0, 1) ** 0.5
        alpha[y, x0:x1] = np.maximum(alpha[y, x0:x1], prof)

def cut(box, name, colour):
    x0, y0, x1, y1 = box
    a = alpha[y0:y1, x0:x1].copy()
    ys, xs = np.where(a > 0.06)
    a = a[ys.min() - 4:ys.max() + 5, xs.min() - 4:xs.max() + 5]
    rgba = np.zeros(a.shape + (4,), np.uint8)
    rgba[..., :3] = colour
    rgba[..., 3] = (a * 255).astype(np.uint8)
    Image.fromarray(rgba).save(name)
    print(name, rgba.shape[1], rgba.shape[0])

root = "D:/projects/niedziejko/assets/images/web/"
for suffix, c in (("ink", (86, 48, 112)), ("paper", (239, 231, 218))):
    cut((150, 500, 590, 730), root + f"salutation-{suffix}.png", c)
    cut((600, 1240, 1290, 1600), root + f"signature-{suffix}.png", c)
