import re

f = open('words_alpha.txt', 'r')
#f = open('words_oxford.txt', 'r')
words = [line.strip() for line in f]
f.close()

letters = 'nlmoewb'
letters = list(letters)

def word_match(word):
    word_letters = list(word)
    return all([letter in letters for letter in word_letters])

matching_words = list(filter(word_match, words))
matching_words = list(filter(lambda word: len(word) > 3, matching_words))
matching_words = list(filter(lambda word: letters[0] in word, matching_words))

print(sorted(matching_words))
