import requests
from xml.etree import ElementTree as ET

url = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
response = requests.get(url)
root = ET.fromstring(response.content)
print(root.findall('./'))

for currency in root.findall('.//Cube'):
    print(currency)
    if currency.find('currency').text == 'JPY':
        rate = float(currency.find('rate').text.replace(',', '.'))
        amount_yen = 100 * rate
        print(f'100 Euro is approximately {amount_yen} Japanese Yen')
