import os
import shutil
from PIL import Image

ICON_SOURCE = r"C:\Users\Gabriel\.gemini\antigravity-ide\brain\3860241d-e376-46e8-83b0-cdfa09c6bd5c\bitweve_app_icon_master_1793557069847.jpg"
BANNER_SOURCE = r"C:\Users\Gabriel\.gemini\antigravity-ide\brain\3860241d-e376-46e8-83b0-cdfa09c6bd5c\bitweve_logo_banner_1793557089574.jpg"

icon_img = Image.open(ICON_SOURCE).convert("RGBA")
banner_img = Image.open(BANNER_SOURCE).convert("RGBA")

# Ensure target directories exist
os.makedirs("assets/icons", exist_ok=True)
os.makedirs("assets/images", exist_ok=True)

# 1. Save master assets
icon_img.resize((1024, 1024), Image.Resampling.LANCZOS).save("assets/icons/app_icon.png")
icon_img.resize((512, 512), Image.Resampling.LANCZOS).save("assets/icons/logo.png")
banner_img.save("assets/images/banner.png")
banner_img.save("assets/images/splash_bg.png")
print("Saved assets/icons and assets/images")

# 2. Android launcher icons
android_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

for folder, size in android_sizes.items():
    dest_dir = os.path.join("android/app/src/main/res", folder)
    os.makedirs(dest_dir, exist_ok=True)
    dest_path = os.path.join(dest_dir, "ic_launcher.png")
    icon_img.resize((size, size), Image.Resampling.LANCZOS).save(dest_path)
    print(f"Updated Android {folder} ({size}x{size})")

# 3. iOS icons
ios_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
if os.path.exists(ios_dir):
    ios_icons = {
        "Icon-App-1024x1024@1x.png": 1024,
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
    }
    for filename, size in ios_icons.items():
        dest_path = os.path.join(ios_dir, filename)
        icon_img.resize((size, size), Image.Resampling.LANCZOS).save(dest_path)
    print("Updated all iOS AppIcon set images")

# 4. Web icons
os.makedirs("web/icons", exist_ok=True)
icon_img.resize((32, 32), Image.Resampling.LANCZOS).save("web/favicon.png")
icon_img.resize((192, 192), Image.Resampling.LANCZOS).save("web/icons/Icon-192.png")
icon_img.resize((512, 512), Image.Resampling.LANCZOS).save("web/icons/Icon-512.png")
icon_img.resize((192, 192), Image.Resampling.LANCZOS).save("web/icons/Icon-maskable-192.png")
icon_img.resize((512, 512), Image.Resampling.LANCZOS).save("web/icons/Icon-maskable-512.png")
print("Updated Web icons and favicon")
print("Icon and branding asset generation complete!")
