import os
import sys
os.environ["PARSE_API_ROOT"] = "http://smart-res.herokuapp.com/parse"

from ParsePy.parse_rest.datatypes import Function, Object, GeoPoint, File, Binary, ParseType
from ParsePy.parse_rest.connection import register
from ParsePy.parse_rest.query import QueryResourceDoesNotExist
from ParsePy.parse_rest.connection import ParseBatcher
from ParsePy.parse_rest.core import ResourceRequestBadRequest, ParseError
from ParsePy.parse_rest.user import User
import urllib.request


APPLICATION_ID = 'SmartRES'
REST_API_KEY ='sm4rtr3s'
MASTER_KEY = 'fur3l153'

register(APPLICATION_ID, REST_API_KEY, master_key=MASTER_KEY)

class Picture(Object):
    pass

propertyId = input("Enter your PropertyID: ")

#Clear folder of all previous .bin items
dir_name = "./"
test = os.listdir(dir_name)

for item in test:
    if item.endswith(".bin"):
        os.remove(os.path.join(dir_name, item))
        
        
pictures = Picture.Query.all()
slideshow = Picture.Query.filter(propertyId=propertyId)
if (len(slideshow) == 0):
    print("No pictures to display. Please upload through the app.")
    sys.exit(0)

from PIL import Image

for pic in slideshow:
    file_name = "img-{}.bin".format(pic.objectId)
    with urllib.request.urlopen(pic.image.url) as response, open(file_name, 'wb') as out_file:
        data = response.read() 
        out_file.write(data)
out_file.close()


import slideshow


