"""Download / generate binary assets that are not stored in git.
Run from the project root:  python tools/prepare_assets.py
- fonts/Bravura.otf          (SMuFL music font, SIL OFL)
- fonts/NotoSansTC-Subset.otf (Noto Sans CJK TC, subset to the characters used in scripts/scenes)
- theme/check_on.png, theme/check_off.png (checkbox icons)
"""
import glob, os, urllib.request
from fontTools import subset
from PIL import Image, ImageDraw

BRAVURA_URL = "https://raw.githubusercontent.com/steinbergmedia/bravura/master/redist/otf/Bravura.otf"
BRAVURA_LICENSE_URL = "https://raw.githubusercontent.com/steinbergmedia/bravura/master/LICENSE.txt"
NOTO_LICENSE_URL = "https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/LICENSE"
NOTO_URL = "https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/OTF/TraditionalChinese/NotoSansCJKtc-Regular.otf"


def download(url, path):
    if os.path.exists(path):
        return
    print("download", url)
    urllib.request.urlretrieve(url, path)


def make_font_subset():
    out = "fonts/NotoSansTC-Subset.otf"
    src = "/tmp/NotoSansCJKtc-Regular.otf"
    download(NOTO_URL, src)
    text = "".join(open(p, encoding="utf-8").read()
                   for p in glob.glob("scripts/*.gd") + glob.glob("scenes/*.tscn"))
    chars = {c for c in text if ord(c) > 127}
    chars |= {chr(i) for i in range(32, 127)} | set("，。！？：；、（）～「」")
    opts = subset.Options()
    opts.layout_features = ["*"]
    opts.name_IDs = ["*"]
    opts.notdef_outline = True
    font = subset.load_font(src, opts)
    s = subset.Subsetter(opts)
    s.populate(unicodes=[ord(c) for c in chars])
    s.subset(font)
    subset.save_font(font, out, opts)
    print("subset", out, len(chars), "chars")


def make_checkbox_icons():
    S, n = 4, 48 * 4
    for name, checked in (("check_on", True), ("check_off", False)):
        path = f"theme/{name}.png"
        if os.path.exists(path):
            continue
        im = Image.new("RGBA", (n, n), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        if checked:
            d.rounded_rectangle([2 * S, 2 * S, n - 2 * S, n - 2 * S], radius=8 * S, fill=(76, 175, 80, 255))
            d.line([(12 * S, 25 * S), (20 * S, 33 * S), (36 * S, 15 * S)], fill="white", width=6 * S, joint="curve")
        else:
            d.rounded_rectangle([3 * S, 3 * S, n - 3 * S, n - 3 * S], radius=8 * S, fill="white",
                                outline=(150, 150, 150, 255), width=3 * S)
        im.resize((48, 48), Image.LANCZOS).save(path)


if __name__ == "__main__":
    os.makedirs("fonts", exist_ok=True)
    download(BRAVURA_URL, "fonts/Bravura.otf")
    download(BRAVURA_LICENSE_URL, "fonts/OFL.txt")
    download(NOTO_LICENSE_URL, "fonts/NotoSansCJK-LICENSE.txt")
    make_font_subset()
    make_checkbox_icons()
