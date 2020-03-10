import csv

from bs4 import BeautifulSoup as bs

from selenium import webdriver
from selenium.webdriver.common.keys import Keys

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException

import os
import urllib

overwrite_existing_files = False

def wait_for_class(class_name):
	try:
		elem = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CLASS_NAME, class_name)))
	except TimeoutException:
		raise Exception('Page took too long to load.')

# Collect all URLs for each available day
archive_url = 'https://web.archive.org/web/*/https://www.worldometers.info/coronavirus/#countries'
driver = webdriver.Firefox()
driver.get(archive_url)

wait_for_class('calendar-day')

date_links = driver.find_elements_by_class_name('calendar-day')
for date_link in date_links:
	date_url = date_link.find_element_by_tag_name('a').get_attribute('href')
	date = date_url.split('/')[4]
	
	if overwrite_existing_files or not date + '.csv' in os.listdir('scrape_data/'):
		date_page = urllib.request.urlopen(date_url)
		date_soup = bs(date_page.read(), features = 'lxml')
		
		candidate_tables = date_soup.findAll('table', {'id': ['main_table_countries', 'table3']})
		if len(candidate_tables) != 1:
			raise Exception('%i candidate tables found, need exactly 1.' % (len(candidate_tables)))
		table = candidate_tables[0]
		rows = table.findAll('tr')
		table_data = [[cell.text.strip() for cell in rows[0].findAll('th')]] + [[cell.text.strip() for cell in row.findAll('td')] for row in rows[1:]]
		
		with open('scrape_data/' + date + '.csv', 'w') as out:
			out_csv = csv.writer(out, lineterminator = '\n')
			out_csv.writerows(table_data)

driver.close()
