import keras.models as km
import keras.layers as kl
import pickle
import pandas as pd
import numpy as np

training_values = pickle.load(open('../data/nnet_data/training_values.pkl', 'rb'))
training_labels = pickle.load(open('../data/nnet_data/training_labels.pkl', 'rb'))

X = training_values / 255
y = np.array(pd.get_dummies(training_labels))

num_labels = y.shape[1]
input_shape = X.shape[1:]

#Define model:
model = km.Sequential([
        kl.Conv2D(32, (3, 3), input_shape = input_shape),
        kl.Activation('relu'),
        kl.Conv2D(32, (3, 3)),
        kl.Activation('relu'),
        kl.MaxPool2D(pool_size = (10, 10)),
        kl.Dropout(0.25),
        kl.Flatten(),
        kl.Dense(128),
        kl.Activation('relu'),
        kl.Dropout(0.5),
        kl.Dense(num_labels),
        kl.Activation('softmax')
        ])
model.compile(loss = 'categorical_crossentropy',
              optimizer = 'adam',
              metrics = ['accuracy'])

model.fit(X, y, batch_size = 16, epochs = 10, validation_split = 0.1)

pickle.dump(model, open('conv_net_1.pkl', 'wb'))
