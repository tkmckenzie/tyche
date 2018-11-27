import io
import re
import xml.etree.cElementTree as ET

print('Starting to read all words.')
f = io.open('enwiktionary-latest-all-titles', 'r', encoding = 'utf-8')
words = set()

for line in f:
    word = line[2:].strip().lower()
    if re.search('^[a-z]+$', word): words.add(word)    
f.close()
print('Finished reading all words.')

#Parse wiktionary xml to determine which words are in English
#f = io.open('enwiktionary-latest-pages-articles.xml', 'r', encoding = 'utf-8')
#out = io.open('sample.txt', 'w', encoding = 'utf-8')
#for i in range(10000):
#    out.write(f.readline())
#out.close()
#f.close()

print('Starting to filter English words.')
english_words = set()
tag_del_str = '{http://www.mediawiki.org/xml/export-0.10/}'
f = ET.iterparse('enwiktionary-latest-pages-articles.xml', events = ['start', 'end'])
while True:
    event, elem = next(f)
    tag = re.sub(tag_del_str, '', elem.tag)
    if tag == 'page' and event == 'start':
        while True:
            event, elem = next(f)
            tag = re.sub(tag_del_str, '', elem.tag)
            if tag == 'title' and event == 'start' and elem.text != None:
                title = elem.text.lower()
                while True:
                    event, elem = next(f)
                    tag = re.sub(tag_del_str, '', elem.tag)
                    if tag == 'text' and event == 'start':
                        while True:
                            event, elem = next(f)
                            tag = re.sub(tag_del_str, '', elem.tag)
                            if tag == 'text' and event == 'end':
                                text = elem.text
                                elem.clear()
                                break
                            elem.clear()
                        elem.clear()
                        break
                    elem.clear()
                elem.clear()
                break
            elem.clear()
        if title in words and '==English==' in text:
            english_words.add(title)
    elem.clear()
english_words = sorted(english_words)
print('Finished filtering English words.')

out = open('words_wiktionary.txt', 'w')
for word in english_words:
    out.write(word + '\n')
out.close()
