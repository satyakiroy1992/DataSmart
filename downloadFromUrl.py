#Greatz thanks to Man Wuzi for this script (http://pastebin.com/nRVXgmqF)
#A little bit modify by me & my bro (Hiep-TH)
 
import urlparse
import urllib2
import os
import sys
 
try:
    from bs4 import BeautifulSoup
except ImportError:
    print "[*] Please download and install Beautiful Soup first"
    sys.exit(0)
 
#url = raw_input("[+] Enter the url: ")
url = sys.argv[1]
#download_path = raw_input("[+] Enter the download path in full: ") 
#http://security.cs.rpi.edu/courses/binexp-spring2015/
download_path = sys.argv[2]
try:
    #set headers to make it look legit for the url
    headers = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
       'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
       'Accept-Encoding': 'none',
       'Accept-Language': 'en-US,en;q=0.8',
       'Connection': 'keep-alive'}
 
    i = 0    #count downloaded file
 
    request = urllib2.Request(url, None, headers) #requests URL with fake header
    html = urllib2.urlopen(request) #open URL and return file-like for page object
     
    html_src = html.read() #get all source code of specific page
    html_src_edited = html_src.replace("--!>", "-->")        #repalce --!> to --> (ex: cseweb.ucsd.edu/classes/su15/cse140-a/syllabus.html)
     
    #soup = BeautifulSoup(html.read()) #to parse the website
    soup = BeautifulSoup(html_src_edited, 'html.parser')
 
    for tag in soup.findAll('a', href=True): #find <a> tags with href in it so you know it is for urls
        #so that if it doesn't contain the full url it can the url itself to it for the download
        tag['href'] = urlparse.urljoin(url, tag['href'])
 
        #this is pretty easy we are getting the extension (splitext) from the last name of the full url(basename)
        #the splitext splits it into the filename and the extension so the [1] is for the second part( the extension)
        ext = os.path.splitext(os.path.basename(tag['href']))[1]
        if ext == '.pdf':
            request = urllib2.Request(tag['href'], None, headers)
            try:
                current = urllib2.urlopen(request)
                f = open(download_path + "/" +os.path.basename(tag['href']), "wb")
                f.write(current.read())
                f.close()
                i+=1
                print "\n[*] Downloaded: %s" %(os.path.basename(tag['href']))
            except:
                print "\n[*] Missing/Non-Existing link: %s" %(tag['href'])
                continue
 
 
except KeyboardInterrupt:
    print "[*] Exiting..."
    sys.exit(1)
 
except urllib2.URLError as e:
    print "[*] Could not get information from server!!"
    sys.exit(2)
 
except:
    print "I don't know the problem but sorry!!"
    sys.exit(3)