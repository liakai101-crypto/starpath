# Subset NotoSansTC-VF.ttf to the glyphs preview.html actually uses.
# All UI strings (both locales) live inline in preview.html, so the file's
# own character inventory is the complete glyph set. ASCII + common
# punctuation ranges are added as a safety floor for dynamic numbers/times.
import re
from pathlib import Path

SRC = Path(r"C:\starpath\preview.html")
FONT = Path(r"C:\starpath\assets\fonts\NotoSansTC-VF.ttf")
OUT = Path(r"C:\starpath\assets\fonts\NotoSansTC-subset.woff2")

text = SRC.read_text(encoding="utf-8")
chars = set(text)
# safety floor: full ASCII printable, Latin-1 punctuation, general punctuation,
# CJK punctuation, fullwidth forms
for lo, hi in [(0x20, 0x7E), (0xA0, 0xFF), (0x2000, 0x206F), (0x3000, 0x303F), (0xFF00, 0xFFEF)]:
    chars.update(chr(c) for c in range(lo, hi + 1))
codepoints = sorted(ord(c) for c in chars if ord(c) >= 0x20)
unicodes = ",".join(f"U+{c:04X}" for c in codepoints)

from fontTools.subset import main as ss_main
import sys

args = [
    str(FONT),
    f"--unicodes={unicodes}",
    f"--output-file={OUT}",
    "--flavor=woff2",
    "--layout-features=*",
    "--name-IDs=1,2,3,4,6",
    "--notdef-outline",
]
sys.argv = ["pyftsubset"] + args
ss_main(args)
print("chars in page:", len(codepoints))
print("out size:", OUT.stat().st_size, "bytes")
