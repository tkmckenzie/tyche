from mnist import MNIST
from matplotlib import pyplot as plt
import numpy as np
import pickle

mndata = MNIST('data')
mndata.gz = True

images, labels = mndata.load_testing()

images = np.array(images) / 255
images = images.reshape(images.shape[0], 28, 28, 1)

model = pickle.load(open('neural_2.pkl', 'rb'))

predictions = model.predict(images)
predictions = list(map(lambda x: np.argmax(x), predictions))

predictions_labels = np.array(list(zip(predictions, labels)))
prediction_errors = np.array(list(map(lambda x: x[0] != x[1], predictions_labels)))

for i in np.where(prediction_errors)[0]:
    print('Predicted: ' + str(predictions[i]))
    print('True: ' + str(labels[i]))
    plt.imshow(images[i,:,:,0])
    plt.show()
    input('Press Enter to continue...')
