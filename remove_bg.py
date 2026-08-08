import sys
from PIL import Image
from rembg import remove

def clean_icon(input_path, output_path):
    print("Loading image...")
    # Read the original image
    with open(input_path, "rb") as i:
        input_data = i.read()
    
    print("Removing background with rembg...")
    # Remove the background using rembg
    output_data = remove(input_data)
    
    print("Processing image data...")
    # Load the background-less image as RGBA using PIL
    from io import BytesIO
    img = Image.open(BytesIO(output_data)).convert("RGBA")
    
    # Create a new pure white image with the same size
    white_bg = Image.new("RGBA", img.size, "WHITE")
    
    # Composite the foreground over the white background
    white_bg.paste(img, (0, 0), img)
    
    # Convert to RGB to save as JPG
    final_img = white_bg.convert("RGB")
    
    print(f"Saving to {output_path}...")
    final_img.save(output_path, "JPEG", quality=95)
    print("Done!")

if __name__ == "__main__":
    import os
    img_path = "assets/images/app_icon.jpg"
    if not os.path.exists(img_path):
        print(f"Error: {img_path} not found.")
        sys.exit(1)
    
    clean_icon(img_path, img_path)
