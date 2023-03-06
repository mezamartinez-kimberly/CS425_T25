
import urllib.request
import json
import pprint
import ssl # for handling ssl certificate error
import sys # for handling utf-8 encoding error when printing proudct name

from urllib.request import Request, urlopen

# ref: https://stackoverflow.com/questions/27835619/urllib-and-ssl-certificate-verify-failed-error
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    # Legacy Python that doesn't verify HTTPS certificates by default
    pass
else:
    # Handle target environment that doesn't support HTTPS verification
    ssl._create_default_https_context = _create_unverified_https_context

# ref: https://stackoverflow.com/questions/27092833/unicodeencodeerror-charmap-codec-cant-encode-characters
sys.stdin.reconfigure(encoding='utf-8')
sys.stdout.reconfigure(encoding='utf-8')


product_code = '096619295203'
api_key = 'd20cfa73c6e8943592d96091a7469ccad33c7b60d59ab8a7923d0adc573bf5d8'

req = Request('https://go-upc.com/api/v1/code/' + product_code)
req.add_header('Authorization', 'Bearer ' + api_key)

content = urlopen(req).read()
data = json.loads(content.decode())

product_name = data["product"]["name"]
product_description = data["product"]["description"]
product_image = data["product"]["imageUrl"]

print("Product Name: " + product_name + "\n")
print("Product Description: " + product_description + "\n")
print("Product Image URL: " + product_image + "\n")
