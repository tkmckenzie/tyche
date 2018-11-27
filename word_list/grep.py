import re
import numpy as np

#f = open('words_alpha.txt', 'r')
#f = open('words_wiktionary.txt', 'r')
f = open('words_scrabble.txt', 'r')
words = [line.strip() for line in f]
f.close()

left_letters = 'qwertasdfgzxcvb'
right_letters = 'yuiophjklbnm'

left_words = list(filter(lambda word: re.search('^[' + left_letters + ']+$', word), words))
right_words = list(filter(lambda word: re.search('^[' + right_letters + ']+$', word), words))

left_max = left_words[np.argmax([len(word) for word in left_words])]
right_max = right_words[np.argmax([len(word) for word in right_words])]

print(left_max + ':' + str(len(left_max)))
print(right_max + ':' + str(len(right_max)))
