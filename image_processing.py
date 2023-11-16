from PIL import Image

def get_bnw(filename):
    im = Image.open(filename, "r")
    pix_val = list(im.getdata())

    out = []
    for pixel in pix_val:
        out.append(sum(pixel)//3)
    
    return out

filename = "cat.jpeg"
print(get_bnw(filename))