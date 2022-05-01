#!/usr/bin/python
# -*- coding: utf-8 -*-
import json
import os
import sys
from mako.template import Template

def writeFile(fileName, source):
    try:
        output_path = "modelOutput/"
        if not os.path.exists(output_path):
            os.makedirs(output_path)
        sourcePath= output_path + fileName
        file = open(sourcePath, "w")
        file.write(source)
    except (Exception), e:
        print "write error: " + e

def generateFile(isResponse, className, templatePath, properties, requestConf, headerList):
    templatePathH = templatePath + '.h'
    templatePathM = templatePath + '.m'
    templateH = Template(filename=templatePathH,input_encoding='utf-8',output_encoding='utf-8')
    templateM = Template(filename=templatePathM,input_encoding='utf-8',output_encoding='utf-8')
    writeFile(className + '.h', templateH.render(className=className, properties=properties, headerList=headerList))
    writeFile(className + '.m', templateM.render(className=className, requestConf=requestConf, headerList=headerList))

def jsonReader(filename):
    with open(filename, "r") as json_file:
        data = json.load(json_file)
        return data

def firstCapitial(name):
    return (name[0].upper() + name[1:])

def parseJsonData(isResponse, jsonData, modelName, requestConf, classPrefix):
    propertyList = []
    headerList = []
    for key in jsonData:
        item =  jsonData[key]
        if isinstance(item, dict):
            modelClass = classPrefix+firstCapitial(key)         
            propertyList.append({'name':key, 'type':modelClass, 'copyType':'strong'})
            headerList.append(modelClass)
            parseJsonData(isResponse, item, key, None, classPrefix)    
        elif isinstance(item, unicode):
            propertyList.append({'name':key, 'type':'NSString', 'copyType':'copy'})
        elif isinstance(item, int):
            propertyList.append({'name':key, 'type':'NSInteger', 'copyType':'assign'})
        elif isinstance(item, list):
            list_item = item[0]
            list_model_name = modelName+key
            modelClass = classPrefix+firstCapitial(list_model_name)
            headerList.append(modelClass)
            propertyList.append({'name':key, 'type':"NSArray<%s *>"%(modelClass), 'copyType':'strong'})
            parseJsonData(isResponse, list_item, list_model_name, None, classPrefix)

    if isResponse:
        generateFile(isResponse, classPrefix+firstCapitial(modelName), './templates/response', propertyList, None, headerList)
    else:
        generateFile(isResponse, classPrefix+firstCapitial(modelName), './templates/request', propertyList, requestConf, headerList)


try:
    requestJsonPath = './mockData/request.json'
    responseJsonPath = './mockData/response.json'
    if len(sys.argv) == 3:
        requestJsonPath = sys.argv[1]
        responseJsonPath = sys.argv[2]

    request_json_data = jsonReader(requestJsonPath)
    requestConf = request_json_data['requestConf']
    classPrefix = requestConf['classPrefix']
    requestParam = request_json_data['requestParam']
    parseJsonData(False, requestParam, 'RequestParam', requestConf, classPrefix)

    response_json_data = jsonReader(responseJsonPath)
    response_result_json = response_json_data['result']; 
    parseJsonData(True, response_result_json, 'ResponseResult', None, classPrefix)    
except (Exception), e:
    print ("generateFile error: " + str(e))
