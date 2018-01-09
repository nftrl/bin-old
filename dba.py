#!/usr/bin/env python3

""" TODO
- test for correct syntax on CATEGORY
- proper formatted help message
- add info about category when printing search query message
- make a class blacklist with methods:
    read - read the blacklist
    remove - remove entry from blacklist. maybe add to another file? for use if
        the id doesn't match any hits. maybe just comment it out.
    log - used to log blacklisted hits, if one wished to see these
"""

import sys
import requests
import bs4
import json


def print_header(text):
    length = 84
    textlength = len(text)
    bar= '=' * ((length - textlength)//2 - 2)

    line = '%s %s %s' % (bar, text, bar)
    if len(line) != 82:
        line += '='
    print(line)


def read_blacklist(path):
    with open(path, 'r') as f:
        blacklist = []
        for line in f:
            entry = line.strip()
            if entry and not entry.startswith('#'):
                blacklist.append(entry.split()[0])
    return blacklist


def search(query, blacklist=[], category='soeg'):
    """Search dba.dk with query and category and print hits.
    
    blacklist is optional. Exclude entry from output if ID is in blacklist.
    'soeg' is the default when no category is used in the search.
    """

    if category == 'soeg':
        print_header(query)
    else:
        print_header('%s : %s' % (category, query))

    url = 'https://www.dba.dk/%s?soeg=%s' % (category, query)
    try:
        r = requests.get(url)
    except OSError as e: 
        # When there is no internet connection, the exception socket.gaierror
        # is raised first, then another ~5 exceptions. I had trouble catching
        # socket.gaierror, but it is a subclass of OSError. Print error message
        # to stdout and exit with exit status 1.
        print()
        print(e)
        print()
        print('An error occurred during requests.get(%s) in search(). Do you have an internet connection?' % (url))
        sys.exit(1)

    try:
        soup = bs4.BeautifulSoup(r.text, "lxml")
    except bs4.FeatureNotFound: # If lxml is not found, try with html.parser
        try:
            soup = bs4.BeautifulSoup(r.text, "html.parser")
        except bs4.FeatureNotFound: # If html.parser is not found, try with whatever
            soup = bs4.BeautifulSoup(r.text)

    count = 0
    blacklisted = 0
    for td in soup.find_all('td'):
        if td.get('class') and 'mainContent' in td.get('class'):
            count += 1

            # Get raw data as string. It is formatted as json. Remove newline
            # and carriage as they seem to cause an error and raise the
            # exception json.decoder.JSONDecodeError.
            data_raw = td.script.string
            data_raw = data_raw.replace('\n', ' ').replace('\r', ' ')
            try:
                data = json.loads(data_raw)
            except json.decoder.JSONDecodeError as e:
                print('ERROR: json.decoder.JSONDecodeError: %s' % (e))
                print('Raw json:')
                print(data_raw) # Print raw json instead of nicely parsed
                print()
                continue # Skip the rest of this for loop iteration
            
            # Check if blacklisted
            for part in data['url'].split('/'):
                if part.startswith('id'):
                    entry_id = part.split('-')[1]
                    break
            if entry_id in blacklist:
                blacklisted += 1
                continue

            print('text:\t%s' % (data['name']))
            print('url:\t%s' % (data['url']))
            print('price:\t%s %s' % (data['offers']['price'], data['offers']['priceCurrency']))
            print()

    if count == 0:
        print('None\n')
    elif blacklisted:
        print('Blacklisted: %i\n' % (blacklisted))


if __name__ == '__main__':
    args = sys.argv[1:] # Read arguments

    if not args or args[0] == '--help':
        print('Usage: dba.py [--help] [ARGUMENT]...')
        print()
        print('Search www.dba.dk for each argument and print results.')
        print('With --help option: print this and exit.')
        print('By Marcus Larsen')
    else:
        blacklist = read_blacklist('/home/nfooatrle/.binrc/dba-blacklist')

        cat = None
        for arg in args:
            if arg.split('=')[0] == '-category':
                cat = arg.split('=')[1]
                continue

            try:
                if cat:
                    search(arg, blacklist, cat)
                    cat = None
                else:
                    search(arg, blacklist)
            except KeyboardInterrupt:
                print()
                break
