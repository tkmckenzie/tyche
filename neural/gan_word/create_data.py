import pandas as pd

f = open('wordlist.txt', 'r')
words = [line.strip() for line in f]
f.close()

max_word_length = max([len(s) for s in words])

def get_dummies(s):
    alpha = 'abcdefghijklmnopqrstuvwxyz '
    
    s_appended = s + ' '*(max_word_length - len(s))
    
    d = pd.get_dummies(list(s_appended + alpha)).iloc[:-27,:]
    return d

word_dummies = list(map(get_dummies, words))