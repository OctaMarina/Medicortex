import requests
from datetime import datetime


def generate_pubmed_search_request(mesh_terms, date_range=None, authors=None):
    """
    Generate a PubMed search request URL.

    Args:
        mesh_terms (list of str): List of MeSH terms to search.
        date_range (tuple of datetime, optional): Tuple containing start and end dates for the search.
        authors (list of str, optional): List of author names to include in the search.

    Returns:
        str: The generated request URL.
    """
    base_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    db = "pubmed"
    terms = [f"{term}[MeSH Terms]" for term in mesh_terms]

    if authors:
        author_terms = [f"{author}[Author]" for author in authors]
        author_query = "+OR+".join(author_terms)
        terms.append(f"({author_query})")

    term_query = "+AND+".join(terms)
    retmode = "json"
    request_url = f"{base_url}?db={db}&term={term_query}&retmode={retmode}"

    if date_range:
        start_date, end_date = date_range
        start_date_str = start_date.strftime("%Y/%m/%d")
        end_date_str = end_date.strftime("%Y/%m/%d")
        date_range_query = f"&mindate={start_date_str}&maxdate={end_date_str}"
        request_url += date_range_query

    return request_url


def execute_pubmed_search(mesh_terms, date_range=None, authors=None):
    """
    Execute a PubMed search and return the list of PubMed IDs.

    Args:
        mesh_terms (list of str): List of MeSH terms to search.
        date_range (tuple of datetime, optional): Tuple containing start and end dates for the search.
        authors (list of str, optional): List of author names to include in the search.

    Returns:
        list of str: List of PubMed IDs.
    """
    search_request = generate_pubmed_search_request(mesh_terms, date_range, authors)
    response = requests.get(search_request)
    response_json = response.json()
    id_list = response_json["esearchresult"]["idlist"]
    return id_list


def get_article_title(pubmed_id):
    """
    Get the title of an article given its PubMed ID.

    Args:
        pubmed_id (str): PubMed ID of the article.

    Returns:
        str: Title of the article.
    """
    base_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"
    db = "pubmed"
    request_url = f"{base_url}?db={db}&id={pubmed_id}&retmode=json"
    response = requests.get(request_url)
    response_json = response.json()
    title = response_json["result"][pubmed_id]["title"]
    return title


def get_articles_info(pubmed_ids):
    """
    Get information for multiple articles given their PubMed IDs.

    Args:
        pubmed_ids (list of str): List of PubMed IDs.

    Returns:
        list of dict: List of dictionaries containing article information (title, id, url).
    """
    base_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"
    db = "pubmed"
    ids_str = ",".join(pubmed_ids)
    request_url = f"{base_url}?db={db}&id={ids_str}&retmode=json"
    response = requests.get(request_url)
    response_json = response.json()
    articles_info = []

    for pubmed_id in pubmed_ids:
        article_info = response_json["result"][pubmed_id]
        title = article_info["title"]
        article_url = f"https://pubmed.ncbi.nlm.nih.gov/{pubmed_id}"
        articles_info.append({"title": title, "id": pubmed_id, "url": article_url})

    return articles_info


def get_articles_list(mesh_terms, date_range=None, authors=None):
    """
    Get information for articles matching given MeSH terms, date range, and authors.

    Args:
        mesh_terms (list of str): List of MeSH terms to search.
        date_range (tuple of datetime, optional): Tuple containing start and end dates for the search.
        authors (list of str, optional): List of author names to include in the search.

    Returns:
        list of dict: List of dictionaries containing article information (title, id, url).
    """
    if date_range and len(date_range) == 2:
        start_date, end_date = date_range
        if not end_date or start_date == end_date:
            end_date = datetime.now()
        date_range = (start_date, end_date)
    elif date_range and len(date_range) == 1:
        start_date = date_range[0]
        end_date = datetime.now()
        date_range = (start_date, end_date)

    id_list = execute_pubmed_search(mesh_terms, date_range, authors)
    articles_info = get_articles_info(id_list)

    return articles_info
