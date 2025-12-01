import base64
import os

# Create images directory if it doesn't exist
os.makedirs('assets/images', exist_ok=True)

# Base64 encoded 1x1 transparent PNG
placeholder = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="

# Create three placeholder images
for i in range(1, 4):
    with open(f'assets/images/placeholder{i}.png', 'wb') as f:
        f.write(base64.b64decode(placeholder))

print("Created 3 placeholder images in assets/images/")
