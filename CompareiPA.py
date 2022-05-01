from sys import argv
import os.path
from os import rename
import string
import filecmp
import re
import pprint
import filecmp, sys, os
from os.path import walk, isfile, join, basename, normpath, splitext
import CompareFolder


def compareiPA(ipa1, ipa2):
    os.system("rm -rf ./Payload")
    os.system("unzip %s > /dev/null" % ipa1)

    name1 = getItemName(ipa1)
    os.system("rm -rf ./%s" % name1)
    os.system("mv ./Payload %s" % name1)

    os.system("unzip %s > /dev/null" % ipa2)

    name2 = getItemName(ipa2)
    os.system("rm -rf ./%s" % name2)
    os.system("mv ./Payload %s" % name2)

    # os.system("rm -rf ./[%s]and[%s]Result.txt" %(name1, name2))

    # result = open("./[%s]and[%s]Result.txt" %(name1, name2), "w")

    # Redirect stdout into a file
    # stdout = sys.stdout

    # sys.stdout = result

    dir1 = './%s/lujinsuo.app' %name1

    dir2 = './%s/lujinsuo.app' % name2

    # compareFolders(dir1, dir2)
    CompareFolder.compare(dir1, dir2)

    # result.close()

    # Restore stdout
    # sys.stdout = stdout

    postCompare(name1, name2)


def postCompare(folder1, folder2):
    os.system("rm -rf ./%s" % folder1)
    os.system("rm -rf ./%s" % folder2)


def getItemName(path):
    str_firtSplit = re.split('/', path)

    firtLen = len(str_firtSplit)

    str_secondSplit = re.split('.ipa', str_firtSplit[firtLen - 1])

    return str_secondSplit[0]


if __name__ == "__main__":
    if len(argv) < 2:
        print ("================================================================================================================")
        print ("======================================== Please enter 2 ipas to run this =======================================")
        print ("================================================================================================================")
    else:
        compareiPA(argv[1], argv[2])
