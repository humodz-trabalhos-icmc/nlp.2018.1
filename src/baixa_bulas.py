import csv
import os
from modules.scraper import *

print('BAIXANDO LISTA DE BULAS')
scrape_all_drugs()
filter_csv()

print('BAIXANDO PDF DE BULAS')
reader = csv.reader('data/bulas.csv')
urls = [row[4] for row in reader]
wget_url_list(urls)

print('CONVERTENDO PARA TXT')
pdf_to_txt()
filter_section()
