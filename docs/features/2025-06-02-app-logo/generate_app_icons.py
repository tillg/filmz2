#!/usr/bin/env python3
"""
Generate all required app icon sizes for iOS and macOS from a source image.
"""

import os
import subprocess
from pathlib import Path

# Icon sizes needed for iOS and macOS
# Format: (size, scale, filename_prefix, idiom)
ICON_SIZES = [
    # iOS sizes
    (20, 2, "icon_20pt", "iphone"),
    (20, 3, "icon_20pt", "iphone"),
    (29, 2, "icon_29pt", "iphone"),
    (29, 3, "icon_29pt", "iphone"),
    (40, 2, "icon_40pt", "iphone"),
    (40, 3, "icon_40pt", "iphone"),
    (60, 2, "icon_60pt", "iphone"),
    (60, 3, "icon_60pt", "iphone"),
    
    # iPad sizes
    (20, 1, "icon_20pt", "ipad"),
    (20, 2, "icon_20pt", "ipad"),
    (29, 1, "icon_29pt", "ipad"),
    (29, 2, "icon_29pt", "ipad"),
    (40, 1, "icon_40pt", "ipad"),
    (40, 2, "icon_40pt", "ipad"),
    (76, 1, "icon_76pt", "ipad"),
    (76, 2, "icon_76pt", "ipad"),
    (83.5, 2, "icon_83.5pt", "ipad"),
    
    # App Store
    (1024, 1, "icon_1024pt", "ios-marketing"),
    
    # macOS sizes
    (16, 1, "icon_16pt", "mac"),
    (16, 2, "icon_16pt", "mac"),
    (32, 1, "icon_32pt", "mac"),
    (32, 2, "icon_32pt", "mac"),
    (128, 1, "icon_128pt", "mac"),
    (128, 2, "icon_128pt", "mac"),
    (256, 1, "icon_256pt", "mac"),
    (256, 2, "icon_256pt", "mac"),
    (512, 1, "icon_512pt", "mac"),
    (512, 2, "icon_512pt", "mac"),
]


def generate_icons(source_path, output_dir):
    """Generate all icon sizes from source image."""
    # Create output directory if it doesn't exist
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Check if source file exists
    if not os.path.exists(source_path):
        print(f"Error: Source file {source_path} not found!")
        return False
    
    # Check if sips is available (macOS image processing tool)
    try:
        subprocess.run(["which", "sips"], check=True, capture_output=True)
    except subprocess.CalledProcessError:
        print("Error: 'sips' command not found. This script requires macOS.")
        return False
    
    print(f"Generating icons from: {source_path}")
    print(f"Output directory: {output_dir}")
    
    for size, scale, prefix, idiom in ICON_SIZES:
        # Calculate actual pixel size
        pixel_size = int(size * scale)
        
        # Generate filename
        if scale == 1:
            filename = f"{prefix}.png"
        else:
            filename = f"{prefix}@{scale}x.png"
        
        output_path = output_dir / filename
        
        # Use sips to resize the image
        cmd = [
            "sips",
            "-z", str(pixel_size), str(pixel_size),  # Resize to square
            source_path,
            "--out", str(output_path),
            "--setProperty", "format", "png"
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"✓ Generated {filename} ({pixel_size}x{pixel_size}px) for {idiom}")
        except subprocess.CalledProcessError as e:
            print(f"✗ Failed to generate {filename}: {e}")
            return False
    
    return True


def update_contents_json(output_dir):
    """Generate Contents.json for the AppIcon.appiconset."""
    contents = {
        "images": [],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    # Map of icon configurations
    for size, scale, prefix, idiom in ICON_SIZES:
        if scale == 1:
            filename = f"{prefix}.png"
        else:
            filename = f"{prefix}@{scale}x.png"
        
        # Format size string
        size_str = f"{int(size)}x{int(size)}" if size % 1 == 0 else f"{size}x{size}"
        
        # Format scale string
        scale_str = f"{int(scale)}x" if scale % 1 == 0 else f"{scale}x"
        
        image_entry = {
            "filename": filename,
            "idiom": idiom,
            "scale": scale_str,
            "size": size_str
        }
        
        contents["images"].append(image_entry)
    
    # Write Contents.json
    import json
    contents_path = output_dir / "Contents.json"
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    
    print(f"\n✓ Generated Contents.json")


def main():
    # Paths
    source_image = "/Users/tgartner/git/filmz2/docs/features/2025-06-02-app-logo/filmz.png"
    output_directory = "/Users/tgartner/git/filmz2/filmz2/Assets.xcassets/AppIcon.appiconset"
    
    # Generate icons
    if generate_icons(source_image, output_directory):
        print("\n✅ All icons generated successfully!")
        
        # Update Contents.json
        update_contents_json(Path(output_directory))
        
        print("\n🎉 App icon implementation complete!")
    else:
        print("\n❌ Icon generation failed!")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())