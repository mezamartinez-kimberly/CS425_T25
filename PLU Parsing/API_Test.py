
import urllib.request
import json
import pprint

from urllib.request import Request, urlopen

product_code = '096619295203
'
api_key = '7b6b90e221a1ff7071abac47a5b8052a0dfe682dd273b1dc1eccd74379be5013'

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
