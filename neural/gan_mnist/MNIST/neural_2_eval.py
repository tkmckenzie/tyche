from mnist import MNIST
import keras.utils as ku
import numpy as np
import pickle

mndata = MNIST('data')
mndata.gz = True

images, labels = mndata.load_testing()

images = np.array(images) / 255
images = images.reshape(images.shape[0], 28, 28, 1)
labels = ku.to_categorical(labels)

model = pickle.load(open('neural_2.pkl', 'rb'))

print(model.evaluate(images, labels))
