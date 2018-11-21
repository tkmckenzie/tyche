import re

f = open('words_alpha.txt', 'r')
words = [line.strip() for line in f]
f.close()

letters = 'tiycnva'
letters = list(letters)

def word_match(word):
    word_letters = list(word)
    return all([letter in letters for letter in word_letters])

matching_words = list(filter(word_match, words))
matching_words = list(filter(lambda word: len(word) > 3, matching_words))
matching_words = list(filter(lambda word: 't' in word, matching_words))

print(sorted(matching_words))
