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
images = images.reshape(images.shape[0], 28, 28, 1)
labels = ku.to_categorical(labels)

model = km.Sequential([
        kl.Convolution2D(32, (3, 3), input_shape = (28, 28, 1)),
        kl.Activation('relu'),
        kl.Convolution2D(32, (3, 3)),
        kl.Activation('relu'),
        kl.MaxPooling2D(pool_size = (2, 2)),
        kl.Dropout(0.25),
        kl.Flatten(),
        kl.Dense(128),
        kl.Activation('relu'),
        kl.Dropout(0.5),
        kl.Dense(10),
        kl.Activation('softmax')
        ])
model.compile(optimizer = 'adam',
              loss = 'categorical_crossentropy',
              metrics = ['accuracy'])

model.fit(images, labels,
          epochs = 10, 
          batch_size = 32,
          validation_split = 0.1)

pickle.dump(model, open('neural_2.pkl', 'wb'))
