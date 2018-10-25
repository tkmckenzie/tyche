from mnist import MNIST
import keras.models as km
import keras.layers as kl
import keras.utils as ku
import numpy as np
import pickle

mndata = MNIST('data')
mndata.gz = True

images, labels = mndata.load_training()

images = np.array(images) / 255
labels = ku.to_categorical(labels)

model = km.Sequential([
        kl.Dense(30, input_shape = (784,)),
        kl.Activation('relu'),
        kl.Dense(10),
        kl.Activation('softmax')
        ])
model.compile(optimizer = 'SGD',
              loss = 'mean_squared_error',
              metrics = ['accuracy'])

model.fit(images, labels,
          epochs = 30, 
          batch_size = 10,
          validation_split = 0.1)

pickle.dump(model, open('neural_1.pkl', 'wb'))
