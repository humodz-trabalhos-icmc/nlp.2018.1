import csv
import os
import numpy as np
from nltk.metrics.distance import edit_distance


DIACRITICS_TABLE = str.maketrans(
    'áâãàéêíóõôúüçÁÂÃÀÉÊÍÓÕÔÚÜÇ',
    'aaaaeeiooouucAAAAEEIOOOUUC',
)


def vectorized(*args, **kwargs):
    def decorator(fn):
        return np.vectorize(fn, *args, **kwargs)
    return decorator


@vectorized(excluded='query')
def distance(name, query):
    return edit_distance(name, query)


def normalize(text):
    text = text.translate(DIACRITICS_TABLE)
    text = text.strip()
    text = text.lower()
    return text


def open_all_documents(csv_fname='data/bulas.csv', from_dir='data/final'):
    doc_filenames = set(os.listdir(from_dir))

    def read_doc(arg1, arg2):
        with open(f'{from_dir}/{arg1}_{arg2}.txt', encoding='utf-8') as f:
            return f.read()

    with open(csv_fname, encoding='utf-8') as f:
        reader = csv.reader(f)

        doc_dict = {
            normalize(row[1]): read_doc(row[2], row[3])
            for row in reader
            if f'{row[2]}_{row[3]}.txt' in doc_filenames
        }

        drug_names = np.array(list(doc_dict))

    return drug_names, doc_dict
