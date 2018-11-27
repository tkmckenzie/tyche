import re
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

base_url = 'http://scrabble.merriam.com/browse/'
#letters = 'abcdefghijklmnopqrstuvwxyz'
letters = 'mnopqrstuvwxyz'
max_page_num = str(10000)
all_words = []

for letter in letters:
    driver = webdriver.Firefox()
    #First get max number of pages
    driver.get(base_url + letter + '/' + max_page_num)
    buttons = driver.find_elements_by_class_name('button')
    prev_button = list(filter(lambda button: 'Previous' in button.text, buttons))[0]
    prev_href = prev_button.get_attribute('href')
    max_pages = int(re.sub('[^0-9]+', '', prev_href)) + 1

    for page_num in range(1, max_pages + 1):
        driver.get(base_url + letter + '/' + str(page_num))
        entries = driver.find_element_by_class_name('entries')
        links = entries.find_elements_by_tag_name('a')
        all_words.extend([link.text for link in links])
    driver.close()

all_words.sort()

out = open('words_scrabble_20181127_1500.txt', 'w')
for word in all_words:
    out.write(word + '\n')
out.close()
