import json
import re
import csv
import xml.etree.ElementTree as etree


# R from python https://stackoverflow.com/questions/19894365/running-r-script-from-python
def configuration():
    config_xml_tree = etree.parse("splitter.xml")
    root = config_xml_tree.getroot()
    for child in root:
        if child.tag == "jsons":
            print(child.findall("json"))


if __name__ == "__main__":
    print("READING XML AND SETUP CONFIGURATION")
    configuration()