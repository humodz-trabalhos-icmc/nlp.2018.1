import csv
import itertools
import os
import re
import random

from urllib import request, parse
from time import time
from bs4 import BeautifulSoup


PDF_DOWNLOAD_URL = 'http://www.anvisa.gov.br/datavisa/fila_bula/frmVisualizarBula.asp?pNuTransacao={}&pIdAnexo={}'  # noqa


class NoResultsError(Exception):
    pass


def get_result_page(index, results):
    params_dict = {
        'hddOrderBy': 'medicamento',
        'hddSortBy': 'asc',
        'hddPageSize': results,
        'hddPageAbsolute': index,
    }

    url = 'http://www.anvisa.gov.br/datavisa/fila_bula/frmResultado.asp'

    query_params = parse.urlencode(params_dict).encode()
    req = request.Request(url, query_params)
    response = request.urlopen(req)

    html = response.read().decode('latin-1')
    return html


def get_data_from_page(html):
    doc_id_regex = re.compile("fVisualizarBula\('(\d*)', '(\d*)'\)")
    soup = BeautifulSoup(html, 'html5lib')
    rows = soup.find(id='tblResultado').tbody.find_all('tr')

    if len(rows) == 0:
        raise NoResultsError

    for row in rows:
        td = row.find_all('td')

        field = td[4].a['onclick']
        match = doc_id_regex.search(field)

        if match is None:
            print('[!] Regex failed:', field)
            continue

        yield {
            'name': td[0].get_text().strip(),
            'arg1': match.group(1),
            'arg2': match.group(2),
        }


def scrape_all_drugs(filename='data/bulas.csv', per_page=100, start=1):
    try:
        start_time = time()
        with open(filename, 'a') as f:
            for i in itertools.count(start=start):
                html = get_result_page(index=i, results=per_page)

                for entry in get_data_from_page(html):
                    if entry['arg1'] != '' and entry['arg2'] != '':
                        url = PDF_DOWNLOAD_URL.format(entry['arg1'], entry['arg2'])
                        line = f'{i},"{entry.name}",{entry.arg1},{entry.arg2},{url}'
                        print(line, file=f)
                        f.flush()

                page = str(i).ljust(1)
                elapsed = time() - start_time
                print(f'Page: {page} Elapsed: {elapsed:.2f}s')
    except NoResultsError:
        pass


def filter_csv(in_file='data/bulas.csv', out_file='data/bulas.csv'):
    filtered = dict()

    with open(in_file) as fin:
        reader = csv.reader(fin)

        for row in reader:
            if row[2] != '' and row[3] != '':
                medicine_name = row[1]
                filtered[medicine_name] = row

        with open(out_file, 'w') as fout:
            fmt = '{},"{}",{},{}'.format
            for key in filtered:
                print(fmt(*filtered[key]), file=fout)


def csv_random(in_file='data/bulas.csv', samples=200):
    with open(in_file, encoding='utf-8') as fin:
        reader = csv.reader(fin)
        urls = [row[4] for row in reader]
        chosen = random.sample(urls, samples)
    return chosen


def download_pdf(arg1, arg2, where='data/pdf'):
    url_format = PDF_DOWNLOAD_URL
    url = url_format.format(arg1, arg2)

    os.makedirs(where, exist_ok=True)
    os.system(f"wget '{url}' -P {where}")


def wget_url_list(urls_txt, where='data/pdf'):
    os.system(f'wget -i {urls_txt} -P {where} --no-clobber')
    rename_documents(where)


def rename_documents(where):
    in_files = os.listdir(where)
    pattern = 'frmVisualizarBula\\.asp@pNuTransacao=(\\d+)&pIdAnexo=(\\d+)'

    def change_filename(in_file):
        groups = re.search(pattern, in_file).groups()
        return f'{where}/{groups[0]}_{groups[1]}.pdf'

    for fin in in_files:
        os.rename(f'{where}/{fin}', change_filename(fin))


def pdf_to_txt(from_dir='data/pdf', to_dir='data/txt', xpdf_path='.'):
    in_files = os.listdir(from_dir)

    os.makedirs(to_dir, exist_ok=True)

    for fin in in_files:
        fname = os.path.splitext(fin)[0]
        fin = f'{from_dir}/{fin}'
        fout = f'{to_dir}/{fname}.txt'

        os.system(f"{xpdf_path}/pdftotext '{fin}' '{fout}'")


def filter_section(from_dir='data/txt', to_dir='data/filtered'):
    in_files = os.listdir(from_dir)

    os.makedirs(to_dir, exist_ok=True)

    for fname in in_files:
        out_fname = to_dir + '/' + fname
        in_fname = from_dir + '/' + fname

        with open(in_fname) as fin:
            lines = fin.readlines()

        found_the_section = False
        wanted_lines = []

        for line in lines:
            start1 = 'PARA QUE ESTE MEDICAMENTO'
            start2 = 'PARA QUÊ ESTE MEDICAMENTO'
            if start1 in line or start2 in line:
                found_the_section = True
            if 'COMO ESTE MEDICAMENTO FUNCIONA' in line:
                if len(wanted_lines) == 0 and found_the_section:
                    wanted_lines.append(line)
                break
            if found_the_section:
                line = line.strip()
                if line != '':
                    wanted_lines.append(line + '\n')

        if len(wanted_lines) > 0:
            with open(out_fname, 'w', encoding='utf-8') as fout:
                print(*wanted_lines, sep='', end='', file=fout)
