from PIL import Image
import os
import numpy as np
import pandas as pd

image_dir = '../data/raw_data/101_ObjectCategories/'

image_sizes = list()

image_category_dirs = os.listdir(image_dir)
for image_category_dir in image_category_dirs:
    image_files = os.listdir(image_dir + image_category_dir)
    for image_file in image_files:
        image = Image.open(image_dir + image_category_dir + '/' + image_file)
        image_sizes.append(image.size)

image_sizes = pd.DataFrame(np.array(image_sizes))

print(image_sizes.mean(axis = 0))
print(image_sizes.min(axis = 0))
print(image_sizes.max(axis = 0))
