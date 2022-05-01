#coding=utf-8
__author__ = 'Cambria'

import sys
import json
import os
import datetime
import collections

import argparse

from mako.template import Template
from mako.lookup import TemplateLookup

import setting

#根据info写入文件
def generateFile(info, templeteName, fileName, options):
    try:
        templetePath = "templates/" + templeteName
        lookup = TemplateLookup(['templates/'])
        mytemplete = Template(lookup=lookup, filename=templetePath, input_encoding="utf8", output_encoding="utf8", encoding_errors="replace")
        username = os.environ.get("USER")

        output_path = "RowOutput/"
        if not os.path.exists(output_path):
            os.makedirs(output_path)

        source_name = output_path + fileName + "." + templeteName.split(".").pop()
        now = datetime.datetime.now()
        date = now.strftime("%y-%m-%d")
        year = now.strftime("%Y")

        source = mytemplete.render(author=username, data=info, classname=fileName, copyright=setting.COPY_RIGHT, project=setting.PROJECT_NAME, date=date, year=year, options=options)

        if os.path.exists(source_name):
            os.remove(source_name)
        with open(source_name, 'w') as f:
            f.write(source)
    except (Exception), e:
        print ("generateFile error: " + str(e))

def get_parser():
    description = 'exmaple:\n python lfGenerateRow.py -s -l 64 -a \n--output ~/Desktop \nLFXExample LFXSecondaryExample'
    parser = argparse.ArgumentParser()
    parser.add_argument('-a', '--autolayout', default=False,\
        action='store_true', help='use autolayout for cell view')
    parser.add_argument('-s', '--split', default=False, \
        action='store_true', help='split the header .h and .m code into different files')
    parser.add_argument('-l', '--height', type=float, default=64, \
        help='default cell height. Ignored when using autolayout')
    parser.add_argument('-o', '--output', default='.', \
        help='output dir for generated files')
    parser.add_argument('names', metavar='class', \
        nargs='+', help='cell class name without suffix `Row`')
    return parser

def do_parse():
    options = get_parser().parse_args()
    return options

def standarlized_class_name(short_name, options, template_name=None):
    if not options.split:
        return short_name + 'Row'
    else:
        class_type = os.path.splitext(template_name)[0]
        return short_name + class_type.capitalize()

def get_standardlized_short_class_name(inputname):
    project_prefix = 'LFX'
    classname = inputname
    if not inputname[:3].lower() == project_prefix.lower():
        classname = project_prefix + inputname
    if classname[-1:3].lower() in ['row', 'cell']:
        classname = inputname[:-3]
    return classname

def get_templates(split):
    if split:
        return ['cell.h', 'cell.m', 'row.h', 'row.m']
    else:
        return ['cell_and_row.h', 'cell_and_row.m']

def main():
    options = do_parse()
    #启动引擎
    for name in options.names:
        short_classname = get_standardlized_short_class_name(name)
        for template_name in get_templates(options.split):
            classname = standarlized_class_name(short_classname, options, template_name)
            generateFile(short_classname, template_name, classname, options)
            print('>' * 6)
            print("Oops~Your Row has been generated, Please check [RowOutput/%s] and move the file into any place you like!" % classname)


if __name__ == '__main__':
    main()





