import pickle
import csv

f = open('data.csv', 'r')
f_csv = csv.reader(f)

data = [line for line in f_csv]

pickle.dump(data, open('pickle_test.pkl', 'wb'))