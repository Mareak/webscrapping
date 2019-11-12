from bs4 import BeautifulSoup
import requests
import unicodedata


def get_links(tag):
    url = 'https://medium.com/tag/' + tag
    links = []
    data = requests.get(url)
    soup = BeautifulSoup(data.content, 'html.parser')
    articles = soup.findAll('div', {"class": "postArticle-readMore"})
    for i in articles:
        links.append(i.a.get('href'))
    return links


def get_article(links):
    articles = []
    for link in links:
        article = {}
        data = requests.get(link)
        soup = BeautifulSoup(data.content, 'html.parser')
        title = soup.findAll('title')[0]
        title = title.get_text()
        article['title'] = unicodedata.normalize('NFKD', title)
        author = soup.findAll('meta', {"name": "author"})[0]
        author = author.get('content')
        article['author'] = unicodedata.normalize('NFKD', author)
        article['link'] = link
        article['title'] = unicodedata.normalize('NFKD', title)
        text = soup.find_all('p', limit=1)
        temptext = []
        count = 0
        for phrase in text:
            if count < 1 and phrase:
                count += 1
                temptext.append(phrase.get_text())
            else:
                break
        article['text'] = ' '.join(temptext)
        articles.append(article)
    return articles


if __name__ == '__main__':
    print(get_article("devops"))
