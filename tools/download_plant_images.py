#!/usr/bin/env python3
"""
Script to download real plant images for the FitQuest companion.
Downloads plant images from Unsplash for each evolution stage.
"""

import os
import urllib.request
from pathlib import Path

# Plant image URLs from Unsplash - real plant photos
PLANT_IMAGES = {
    'seed.png': 'https://images.unsplash.com/photo-1516253593875-bd7ba052fbc5?w=400&h=400&fit=crop&auto=format',
    'sprout.png': 'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=400&h=400&fit=crop&auto=format',
    'sapling.png': 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=400&fit=crop&auto=format',
    'tree.png': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=400&fit=crop&auto=format',
    'ancient_tree.png': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=400&fit=crop&auto=format',
}

def download_image(url: str, filepath: Path):
    """Download an image from URL and save to filepath."""
    try:
        print(f"Downloading {filepath.name}...")
        urllib.request.urlretrieve(url, filepath)
        print(f"[OK] Downloaded {filepath.name}")
        return True
    except Exception as e:
        print(f"[ERROR] Error downloading {filepath.name}: {e}")
        return False

def main():
    # Create companion directory if it doesn't exist
    companion_dir = Path('assets/images/companion')
    companion_dir.mkdir(parents=True, exist_ok=True)
    
    print("Downloading plant images for FitQuest companion...")
    print("=" * 50)
    
    success_count = 0
    for filename, url in PLANT_IMAGES.items():
        filepath = companion_dir / filename
        if download_image(url, filepath):
            success_count += 1
    
    print("=" * 50)
    print(f"Downloaded {success_count}/{len(PLANT_IMAGES)} plant images")
    print(f"Images saved to: {companion_dir.absolute()}")
    
    if success_count == len(PLANT_IMAGES):
        print("\n[SUCCESS] All plant images downloaded successfully!")
        print("The app will now use these real plant images instead of network URLs.")
    else:
        print(f"\n[WARNING] Only {success_count} images downloaded successfully.")

if __name__ == '__main__':
    main()

