import xml.etree.ElementTree as ET
import sys
import pickle
import time

tree = ET.parse(sys.argv[1]) #parse xml file
root = tree.getroot()

#get todays date to use in filename
date = str(time.strftime("%Y%m%d"))

#open xml file containing log of traffic messages
traffic_messages = open('../Data/' + date + '_traffic_messages.xml', 'a')

#load list of previous message numbers
try:
    with open('.prev_messages', 'rb') as f:
        prev_messages = pickle.load(f)
except (EOFError, IOError): #these errors are thrown if file doesn't excist or is empty
    prev_messages = []

new_messages = []

#find new messages and add them to log of traffic messages
for element in root.iter('message'):
    message_nr = element.find('messagenumber').text
    new_messages.append(message_nr)
    if (message_nr not in prev_messages):
        traffic_messages.write(ET.tostring(element))

#store list of message numbers
with open('.prev_messages', 'wb') as f:
    pickle.dump(new_messages, f)
