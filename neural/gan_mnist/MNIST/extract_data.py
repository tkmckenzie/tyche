from mnist import MNIST

mndata = MNIST('data')
mndata.gz = True

images, labels = mndata.load_training()