import os
import sys
os.environ["PARSE_API_ROOT"] = "http://smart-res.herokuapp.com/parse"

from parse_rest.datatypes import Function, Object, GeoPoint, File, Binary, ParseType
from parse_rest.connection import register
from parse_rest.query import QueryResourceDoesNotExist
from parse_rest.connection import ParseBatcher
from parse_rest.core import ResourceRequestBadRequest, ParseError
from parse_rest.user import User
import urllib.request


APPLICATION_ID = 'SmartRES'
REST_API_KEY ='sm4rtr3s'
MASTER_KEY = 'fur3l153'

register(APPLICATION_ID, REST_API_KEY, master_key=MASTER_KEY)

class Pictures(Object):
    pass

propertyId = input("Enter your PropertyID: ")

pictures = Pictures.Query.all()
slideshow = Pictures.Query.filter(propertyId=propertyId)
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


import importlib

importlib.import_module("slideshow-2.py")


