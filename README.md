Esta pasta contém todos os scripts que foram usados para baixar e processsar as bulas, assim como o script do servidor.

Dependências do projeto:
* wget
* xpdf-tools
* R
    * Pacote UDPipe
* Python 3
    * Pacote beautifulsoup
    * Pacote Flask

As bulas processadas estão sendo enviados junto com o projeto, então para rodar o site só é necessário Python 3 com Flask instalado.


scraper.py: Funções para baixar e extrair o texto das bulas
annotate.r: Roda um parser de dependência nos textos extraídos
process.r: A partir do resultado da anotação, retorna o resultado que queremos
server.py: Roda o site em si

Para rodar o site, é necessário realizar os seguintes comandos na raiz do projeto:

export FLASK_APP = src/server.py
flask run
