from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import ElementClickInterceptedException
import time

#Get word list
#f = open('words_alpha.txt', 'r')
#f = open('words_corncob.txt', 'r')
#f = open('words_michigan.txt', 'r')
#f = open('words_oxford.txt', 'r')
f = open('words_scrabble.txt', 'r')
#f = open('words_wiktionary.txt', 'r')
words = [line.strip() for line in f]
f.close()

#Open driver, click play, find letter and enter buttons
driver = webdriver.Firefox()
driver.get('https://www.nytimes.com/puzzles/spelling-bee')

time.sleep(5)
driver.execute_script('window.scrollTo(0, 500)')

play_button = list(filter(lambda element: element.text == 'PLAY', driver.find_elements_by_class_name('sb-modal-button')))[0]
play_button.click()

hive = driver.find_element_by_class_name('hive')
letters = hive.text.split('\n')
letters = [letter.lower() for letter in letters]

letter_buttons = hive.find_elements_by_class_name('hive-cell')
letter_buttons = {letter_button.text.strip().lower():letter_button for letter_button in letter_buttons}

enter_button = list(filter(lambda element: element.text == 'Enter', driver.find_elements_by_class_name('hive-action')))[0]

#Find all matching words
def word_match(word):
    word_letters = list(word)
    return all([letter in letters for letter in word_letters])

matching_words = list(filter(word_match, words))
matching_words = list(filter(lambda word: len(word) > 3, matching_words))
matching_words = list(filter(lambda word: letters[0] in word, matching_words))

matching_words.sort()

#Input words
for word in matching_words:
    for letter in word:
        try:
            letter_buttons[letter].click()
        except ElementClickInterceptedException:
            time.sleep(5)
            keep_playing_button = list(filter(lambda element: element.text == 'Keep playing', driver.find_elements_by_class_name('sb-modal-button')))[0]
            keep_playing_button.click()
            letter_buttons[letter].click()
    enter_button.click()
    time.sleep(1)
