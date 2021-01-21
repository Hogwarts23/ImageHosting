import winsound
from random import randrange
from selenium import webdriver  
from selenium.common.exceptions import NoSuchElementException  
from selenium.webdriver.common.keys import Keys  
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import urllib.request
import time
import datetime


urlpage1 = "https://apps4.health.ny.gov/doh2/applinks/cdmspr/2/counties?OpID=50503454"  
urlpage2 = "https://apps2.health.ny.gov/doh2/applinks/cdmspr/2/counties?OpID=50502400"
# page = urllib.request.urlopen(urlpage)
# soup = BeautifulSoup(page,'html.parser') 
options = Options()
# options.headless = True
user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.50 Safari/537.36'
options.add_argument(f'user-agent={user_agent}')
options.add_argument('--allow-running-insecure-content')
options.add_argument("--window-size=1920,1080")
options.add_argument("--disable-extensions")
options.add_argument("--proxy-server='direct://'")
options.add_argument("--proxy-bypass-list=*")
options.add_argument("--start-maximized")
options.add_argument('--headless')
options.add_argument('--disable-gpu')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--no-sandbox')
options.add_argument('--ignore-certificate-errors')


# options = Options()
# options.headless = True
# # i=0
breaker1 = False
breaker2 = False
while True:
	# i=i+1
	browser1 = webdriver.Chrome(options=options,executable_path='C:\\Tools\\chromedriver.exe')
	browser2 = webdriver.Chrome(options=options,executable_path='C:\\Tools\\chromedriver.exe')
	browser1.get(urlpage1)  
	browser2.get(urlpage2)  
	time.sleep(2)
	response1 = browser1.page_source  
	response2 = browser2.page_source 
	browser1.quit()
	browser2.quit()

	soup1 = BeautifulSoup(response1,'html.parser') 
	entry1 = soup1.findAll(class_="col-sm-11 col-md-10 col-lg-11 col-xl-11")
	soup2 = BeautifulSoup(response2,'html.parser') 
	entry2 = soup2.findAll(class_="col-sm-11 col-md-10 col-lg-11 col-xl-11")

	if entry1 is not None:
		for i in range(int(len(entry1)/2)):
			# print(entry[i*2+1])
			s = str(entry1[2*i+1])
			x = s.find("January") + s.find("February") #+ s.find("March")
			if x>=0:
				nloc = s.find("Appointments Available:")+28
				nend = s.find('\n',nloc)
				if int(s[nloc:nend-6]) > 0:
					breaker1 = True
					break
	if entry2 is not None:
		for i in range(int(len(entry2)/2)):
			# print(entry[i*2+1])
			s = str(entry2[2*i+1])
			x = s.find("January") + s.find("February") #+ s.find("March")
			if x>=0:
				nloc = s.find("Appointments Available:")+28
				nend = s.find('\n',nloc)
				if int(s[nloc:nend-6]) > 0:
					breaker2 = True
					break
	if breaker1 or breaker2:
		break
	time.sleep(20+randrange(10))


if breaker1:
	print("There are appointments available in SUNY POLY, at ",datetime.datetime.now())
if breaker2:
	print("There are appointments available in State Fair, at ",datetime.datetime.now())

freqs = [523,587,659,523,784,880,880,1046,880,784,880,880,1046,784,880,659,880,784,659,784,659,523,587,659,523]
duration= [200,200,200,200,800,200,200,200,200,800,200,200,400,200,200,400,200,200,200,200,200,200,200,200,800]
 
for i in range(len(freqs)*4):
	freq = freqs[i%len(freqs)]
	time = duration[i%len(freqs)] 
	# print(freq,time)
	winsound.Beep(freq, time)