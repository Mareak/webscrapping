"""Web app flask 2"""

import time
import unittest
from flask_restful import Resource, Api
from flask import Flask, render_template, session, request, g, jsonify
import scrap
import os
import mysql.connector as mariadb

app = Flask(__name__)
api = Api(app)
app.secret_key = os.environ["SECRET_KEY"]


# url => $(IP)/api?search=test  curl => curl -X GET "$(IP)/api?search=test"
class Research(Resource):
    """  API """
    def get(self):
        """ Retour de l'api """
        if 'search' in request.args:
            links = scrap.get_links(request.args['search'])
        else:
            links = scrap.get_links("devops")
        articles = scrap.get_article(links)
        return jsonify(articles)


@app.before_request
def before_request():
    """ Fonction qui sort le temps d'execution """
    g.request_start_time = time.time()
    g.request_time = lambda: "%.5fs" % (time.time() - g.request_start_time)


@app.route('/', methods=['GET'])
def index():
    """ Index du site  """
    message = 'Bienvenue sur le site de scrapping medium :'
    mariadb_connection = mariadb.connect(host="mariadb",user=os.environ["MYSQL_USER"], password=os.environ["MYSQL_PASSWORD"], database=os.environ["MYSQL_DATABASE"])
    cursor = mariadb_connection.cursor()
    IP=request.environ.get('HTTP_X_REAL_IP', request.remote_addr)
    return render_template('index.html', message=message)

@app.route('/contact', methods=['GET'])
def contact():
    """ Page contact du site """
    info = "Gitlab"
    link = 'https://github.com/Mareak/webscrapping-medium'
    return render_template('info.html', info=info, link=link)


@app.route('/about', methods=['GET'])
def about():
    """ Page about du site  """
    info = "Readme"
    link = 'https://github.com/Mareak/webscrapping-medium/blob/master/README.md'
    return render_template('info.html', info=info, link=link)


@app.route('/research', methods=['POST'])
def redirect():
    """ Page research du site qui fait le scrapping """
    tag = request.form['research']
    try:
        if session[tag]:
            return render_template('research.html', content=session[tag])
    except KeyError:
        pass
    url = scrap.get_links(tag)
    content = scrap.get_article(url)
    session[tag] = content
    return render_template('research.html', content=content)


@app.route('/research_cache=<search>', methods=['GET'])
def research_cache(search):
    """ Page qui affiche le cache """
    content = session[search]
    return render_template('research.html', content=content)


@app.route('/cache', methods=['GET'])
def histo():
    """ Page qui cree le cache """
    message = 'Votre cache contient :'
    histo = []
    for search in session.keys():
        if session[search]:
            histo.append((search, len(session[search])))
    return render_template('histo.html', message=message, histo=histo)


api.add_resource(Research, '/api')


class BasicTests(unittest.TestCase):
    """ Test unitaire """
    def setUp(self):
        """ Test unitaire """
        self.app = app.test_client()

    def test_main_page(self):
        """ Test unitaire sur l'index """
        response = self.app.get('/', follow_redirects=True)
        self.assertEqual(response.status_code, 200)

    def test_contact_page(self):
        """ Test unitaire sur contact"""
        response = self.app.get('/contact', follow_redirects=True)
        self.assertEqual(response.status_code, 200)

    def test_about_page(self):
        """ Test unitaire sur about """
        response = self.app.get('/about', follow_redirects=True)
        self.assertEqual(response.status_code, 200)

    def test_cache_page(self):
        """ Test unitaire sur cache """
        response = self.app.get('/cache', follow_redirects=True)
        self.assertEqual(response.status_code, 200)

    def test_request(self):
        """ Test unitaire sur research"""
        response = self.app.post('/research', data={"research": "test"}, follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIsNot(response, [' '])

    def test_api(self):
        """ Test unitaire sur l'api """
        response = self.app.get('/api?search=cat', follow_redirects=True)
        self.assertIsNot(response, [' '])
        self.assertEqual(response.status_code, 200)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)#, ssl_context=('cert.pem', 'key.pem'))
