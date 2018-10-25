from mnist import MNIST
import numpy as np
import keras.utils as ku
import pickle

mndata = MNIST('data')
mndata.gz = True

images, labels = mndata.load_testing()
images = np.array(images) / 255
labels = ku.to_categorical(labels)

model = pickle.load(open('neural_1.pkl', 'rb'))

print(model.evaluate(images, labels))
