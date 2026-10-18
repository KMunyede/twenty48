import os
import sys
from PIL import Image, ImageDraw, ImageFont

RAW_DIR = os.path.join("store_assets", "raw")
STORE_DIR = "store_assets"

def process_screenshots():
    raw_files = ["screenshot_1.png", "screenshot_2.png", "screenshot_3.png"]
    orig_info = []

    for i, raw_name in enumerate(raw_files, start=1):
        raw_path = os.path.join(RAW_DIR, raw_name)
        if not os.path.exists(raw_path):
            raise FileNotFoundError(f"Missing raw screenshot: {raw_path}")

        im = Image.open(raw_path)
        w, h = im.size
        orig_info.append(f"{w}x{h}")

        # Crop top status bar (~4%) and bottom nav (~2%) if present
        top_crop = int(h * 0.04)
        bottom_crop = int(h * 0.02)
        cropped_im = im.crop((0, top_crop, w, h - bottom_crop))
        cw, ch = cropped_im.size

        # Ensure height <= 2 * width
        if ch > 2 * cw:
            excess = ch - (2 * cw)
            crop_top_extra = excess // 2
            crop_bot_extra = excess - crop_top_extra
            cropped_im = cropped_im.crop((0, crop_top_extra, cw, ch - crop_bot_extra))

        final_im = cropped_im.resize((1080, 2160), Image.Resampling.LANCZOS).convert("RGB")
        out_path = os.path.join(STORE_DIR, f"phone_{i}.png")
        final_im.save(out_path, "PNG")

    return orig_info

def process_icon():
    icon_source = "assets/icon.png"
    if not os.path.exists(icon_source):
        raise FileNotFoundError(f"Icon source not found: {icon_source}")
    im = Image.open(icon_source)
    orig_size = im.size
    upscaled = orig_size[0] < 512 or orig_size[1] < 512

    icon_512 = im.resize((512, 512), Image.Resampling.LANCZOS).convert("RGBA")
    out_path = os.path.join(STORE_DIR, "icon_512.png")
    icon_512.save(out_path, "PNG")
    return icon_source, f"{orig_size[0]}x{orig_size[1]}", upscaled

def load_font(font_names, size):
    for fn in font_names:
        try:
            return ImageFont.truetype(fn, size)
        except Exception:
            pass
    return ImageFont.load_default()

def process_feature_graphic():
    W, H = 1024, 500
    bg_color = (43, 47, 54) # #2B2F36 dark grey
    img = Image.new("RGB", (W, H), bg_color)
    draw = ImageDraw.Draw(img)

    title_font = load_font(["arialbd.ttf", "arial.ttf", "segoeui.ttf"], 56)
    subtitle_font = load_font(["arial.ttf", "segoeui.ttf"], 28)
    tile_font = load_font(["arialbd.ttf", "arial.ttf"], 32)

    title_text = "2048 GrandMasters"
    sub_text = "Merge. Plan. Master."

    draw.text((W // 2, 80), title_text, fill=(255, 255, 255), font=title_font, anchor="mm")
    draw.text((W // 2, 140), sub_text, fill=(230, 210, 180), font=subtitle_font, anchor="mm")

    tiles = [
        {"val": "2", "bg": (238, 228, 218), "fg": (119, 110, 101)},
        {"val": "8", "bg": (242, 177, 121), "fg": (249, 246, 242)},
        {"val": "64", "bg": (246, 94, 59), "fg": (249, 246, 242)},
        {"val": "512", "bg": (237, 200, 80), "fg": (249, 246, 242)},
        {"val": "2048", "bg": (230, 81, 0), "fg": (249, 246, 242)},
    ]

    tile_size = 130
    gap = 24
    total_width = len(tiles) * tile_size + (len(tiles) - 1) * gap
    start_x = (W - total_width) // 2
    top_y = 220

    for i, t in enumerate(tiles):
        tx = start_x + i * (tile_size + gap)
        ty = top_y
        draw.rounded_rectangle([tx, ty, tx + tile_size, ty + tile_size], radius=16, fill=t["bg"])
        draw.text((tx + tile_size // 2, ty + tile_size // 2), t["val"], fill=t["fg"], font=tile_font, anchor="mm")

    out_path = os.path.join(STORE_DIR, "feature_1024x500.png")
    img.save(out_path, "PNG")

def validate():
    results = {}

    for i in range(1, 4):
        p = os.path.join(STORE_DIR, f"phone_{i}.png")
        im = Image.open(p)
        size_bytes = os.path.getsize(p)
        assert im.size == (1080, 2160), f"phone_{i}.png invalid size {im.size}"
        assert im.mode == "RGB", f"phone_{i}.png invalid mode {im.mode}"
        results[f"phone_{i}"] = {"size": f"{im.size[0]}x{im.size[1]}", "mode": im.mode, "bytes": size_bytes}

    icon_p = os.path.join(STORE_DIR, "icon_512.png")
    icon_im = Image.open(icon_p)
    icon_bytes = os.path.getsize(icon_p)
    assert icon_im.size == (512, 512), f"icon_512.png invalid size {icon_im.size}"
    assert icon_im.mode == "RGBA", f"icon_512.png invalid mode {icon_im.mode}"
    assert icon_bytes < 1024 * 1024, f"icon_512.png too large ({icon_bytes} bytes)"
    results["icon"] = {"size": "512x512", "mode": icon_im.mode, "bytes": icon_bytes}

    feat_p = os.path.join(STORE_DIR, "feature_1024x500.png")
    feat_im = Image.open(feat_p)
    feat_bytes = os.path.getsize(feat_p)
    assert feat_im.size == (1024, 500), f"feature_1024x500.png invalid size {feat_im.size}"
    assert feat_im.mode == "RGB", f"feature_1024x500.png invalid mode {feat_im.mode}"
    assert feat_bytes < 15 * 1024 * 1024, f"feature_1024x500.png too large ({feat_bytes} bytes)"
    results["feature_graphic"] = {"size": "1024x500", "mode": feat_im.mode, "bytes": feat_bytes}

    return results

if __name__ == "__main__":
    orig_ss = process_screenshots()
    icon_src, icon_orig_sz, upscaled = process_icon()
    process_feature_graphic()
    val = validate()
    print("VALIDATION SUCCESSFUL")
    print("Orig Screenshots:", orig_ss)
    print("Icon Source:", icon_src, icon_orig_sz, "Upscaled:", upscaled)
    print("Validation:", val)
