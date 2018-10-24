from PIL import Image
import os
import shutil

#Directory definitions
image_dir = '../data/raw_data/101_ObjectCategories/'
output_dir = '../data/resize_data/'

#Image resize dimensions
image_size = (300, 200)

#Remove existing output directories and re-create
shutil.rmtree(output_dir, ignore_errors = True)
os.mkdir(output_dir)

#Resize each image and save
image_category_dirs = os.listdir(image_dir)
for image_category_dir in image_category_dirs:
    os.mkdir(output_dir + image_category_dir)
    image_files = os.listdir(image_dir + image_category_dir)
    for image_file in image_files:
        image = Image.open(image_dir + image_category_dir + '/' + image_file).convert('RGB')
        image = image.resize(image_size, Image.BICUBIC)
        image.save(output_dir + image_category_dir + '/' + image_file)
