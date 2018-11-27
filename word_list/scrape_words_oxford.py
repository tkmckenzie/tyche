from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

driver = webdriver.Firefox()
driver.get('https://www.oxfordlearnersdictionaries.com/us/wordlist/english/oxford3000/')

all_words = []

letter_links_box = driver.find_element_by_class_name('hide_phone')
letter_links = letter_links_box.find_elements_by_tag_name('a')
letter_links = [letter_link.get_attribute('href') for letter_link in letter_links]

def get_words(driver):
    next_page_exists = True
    all_words = []
    while next_page_exists:
        word_box = driver.find_element_by_id('entrylist1')
        words = word_box.text.split('\n')
        all_words.extend(words)
        
        paging_links = driver.find_element_by_class_name('paging_links')
        try:
            next_page_link = paging_links.find_element_by_link_text('>')
            next_page_link.click()
        except NoSuchElementException:
            next_page_exists = False
    
    return all_words

all_words = get_words(driver)
for letter_link in letter_links:
    driver.get(letter_link)
    all_words.extend(get_words(driver))

output_file = open('words_oxford.txt', 'w')
for word in all_words:
    output_file.write(word + '\n')
output_file.close()

driver.close()
