import json
import flask
import numpy as np

import modules.server_utils as utils


drug_names, doc_dict = utils.open_all_documents()
app = flask.Flask(__name__)


@app.route('/')
def index():
    return flask.redirect('/server_files/index.html')


@app.route('/server_files/<path:path>')
def send_public_file(path):
    return flask.send_from_directory('../server_files', path)


@app.route('/search')
def search():
    args = flask.request.args

    if 'query' not in args:
        return '400 Bad Request', 400

    query = utils.normalize(args.get('query'))
    dist = utils.distance(drug_names, query)
    best_match = drug_names[np.argmin(dist)]

    response = {
        'drug_name': best_match.title(),
        'document': doc_dict[best_match]
    }

    return flask.Response(json.dumps(response), mimetype='application/json')
