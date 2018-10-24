import imageio
import os
import shutil
import numpy as np
import pandas as pd
from functools import reduce
import pickle

#Directory definitions
image_dir = '../data/resize_data/'
output_dir = '../data/nnet_data/'

#Training/testing split
training_proportion = 0.8

#Remove existing output directories and re-create
shutil.rmtree(output_dir, ignore_errors = True)
os.mkdir(output_dir)

#Set seed for reproducibility
np.random.seed(123)

#Label recoding
def recode(s):
    if s == 'Faces_easy':
        return 'Faces'
    else:
        return s

#Extracting image data and saving
nnet_data = list()

image_category_dirs = os.listdir(image_dir)
image_category_dirs = list(filter(lambda x: not x in ['BACKGROUND_Google'], image_category_dirs))
for image_category_dir in image_category_dirs:
    image_files = os.listdir(image_dir + image_category_dir)
    for image_file in image_files:
        image_data = np.array(imageio.imread(image_dir + image_category_dir + '/' + image_file))
        nnet_data.append((image_data, recode(image_category_dir)))

nnet_df = pd.DataFrame(nnet_data)
nnet_df.columns = ['data', 'label']

print('Total dataset size: ' + str(nnet_df.shape[0]))

nnet_training = list()
nnet_testing = list()

categories = nnet_df['label'].drop_duplicates().values
category = categories[0]

for category in categories:
    nnet_df_subset = nnet_df[nnet_df['label'] == category]
    
    shuffled_rows = np.random.permutation(np.arange(nnet_df_subset.shape[0]))
    cutoff = np.floor(nnet_df_subset.shape[0] * training_proportion)
    
    nnet_training.append(nnet_df_subset[shuffled_rows <= cutoff])
    nnet_testing.append(nnet_df_subset[shuffled_rows > cutoff])

nnet_training = reduce(lambda df1, df2: pd.concat((df1, df2), axis = 0), nnet_training)
nnet_testing = reduce(lambda df1, df2: pd.concat((df1, df2), axis = 0), nnet_testing)

print('Training dataset size: ' + str(nnet_training.shape[0]))
print('Testing dataset size: ' + str(nnet_testing.shape[0]))

nnet_training_values = np.moveaxis(np.stack(nnet_training.iloc[:,0].values, axis = 3), 3, 0)
nnet_training_labels = nnet_training['label'].values

nnet_testing_values = np.moveaxis(np.stack(nnet_testing.iloc[:,0].values, axis = 3), 3, 0)
nnet_testing_labels = nnet_testing['label'].values

pickle.dump(nnet_training_values, open(output_dir + 'training_values.pkl', 'wb'))
pickle.dump(nnet_training_labels, open(output_dir + 'training_labels.pkl', 'wb'))

pickle.dump(nnet_testing_values, open(output_dir + 'testing_values.pkl', 'wb'))
pickle.dump(nnet_testing_labels, open(output_dir + 'testing_labels.pkl', 'wb'))
