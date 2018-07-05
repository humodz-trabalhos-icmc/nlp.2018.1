import csv
from modules.scraper import *


reader = csv.reader('data/bulas.csv')

urls = [row[4] for row in reader]

wget_url_list(urls)
pdf_to_txt()
filter_section()
