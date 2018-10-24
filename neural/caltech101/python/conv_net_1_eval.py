import pickle
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

testing_values = pickle.load(open('../data/nnet_data/testing_values.pkl', 'rb'))
testing_labels = pickle.load(open('../data/nnet_data/testing_labels.pkl', 'rb'))

model = pickle.load(open('conv_net_1.pkl', 'rb'))

X = testing_values / 255
y = np.array(pd.get_dummies(testing_labels))

labels = np.array(sorted(pd.DataFrame(testing_labels).drop_duplicates().values[:,0]))
num_test_obs = X.shape[0]

#Make predictions
predictions = model.predict(X)

#Basic evaluation
#model.evaluate(X, y)

#Seeing which images are incorrect
#for i in range(num_test_obs):
#    predicted_label = labels[np.argmax(predictions[i,:])]
#    true_label = labels[y[i,:] == 1][0]
#    
#    if (predicted_label != true_label):
#        print('Predicted: ' + predicted_label)
#        print('True: ' + true_label)
#        plt.imshow(testing_values[i,:,:,:])
#        plt.show()
#        
#        if input('Press Enter to continue, type "stop" to stop...') == 'stop': break
#    else:
#        print('Predicted: ' + predicted_label)
#        print('True: ' + true_label)
#        plt.imshow(testing_values[i,:,:,:])
#        plt.show()
#        
#        if input('Press Enter to continue, type "stop" to stop...') == 'stop': break

#Performance by category
def is_correct(i):
    predicted_label = labels[np.argmax(predictions[i,:]), 0]
    true_label = labels[y[i,:] == 1, 0][0]
    return (true_label, predicted_label == true_label)
results_df = pd.DataFrame(list(map(is_correct, range(num_test_obs))))
results_df.columns = ['Label', 'Correct']

print(results_df['Correct'].mean())
print(results_df.groupby('Label')['Correct'].mean())
