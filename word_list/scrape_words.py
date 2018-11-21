from selenium import webdriver
from selenium.webdriver.common.keys import Keys

driver = webdriver.Firefox()
driver.get('https://www.oxfordlearnersdictionaries.com/us/wordlist/english/oxford3000/')

all_words = []

letter_links_box = driver.find_element_by_class_name('hide_phone')

asdf
while True:
    word_box = driver.find_element_by_id('entrylist1')
    words = word_box.text.split('\n')
    all_words.extend(words)
