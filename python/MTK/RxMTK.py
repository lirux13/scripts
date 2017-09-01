#/usr/bin/python
import os
import re

def ReadMakeFile(makeName):
    macroDict = {'a':'b'}
    macroDict.clear()
    fileContent = ''

    try:
        mmFile = open(makeName)
        fileContent = mmFile.readlines()
        mmFile.close()
    except:
        print('Open \'' + makeName + '\' Fail!!!');

    for line in fileContent:
        line = line.strip()
        if '#' in line:
            temp = line.split('#')
            line = temp[0]
        if 0 == len(line):
            continue
        if '$' in line or '+=' in line or '\\' in line:
            continue
        #print(line)
        array = line.split('=')
        if len(array) != 2 or 0 == len(array[1]): 
            continue
        key = array[0].strip()
        value = array[1].strip()
        #print(key + ' = ' + value)
        macroDict[key] = value

    return macroDict

def ReadMakeFile2(makeName):
    macroDict = {'a':'b'}
    macroDict.clear()
    fileContent = ''

    try:
        mmFile = open(makeName)
        fileContent = mmFile.readlines()
        mmFile.close()
    except:
        print('Open \'' + makeName + '\' Fail!!!');

    for line in fileContent:
        line = line.strip()
        if '#' in line:
            temp = line.split('#')
            line = temp[0]
        if 0 == len(line):
            continue
        if '$' in line or '+=' in line or '\\' in line:
            continue
        macroRegex = re.compile(r'(\w+)\s*=\s*(\w+)')
        mo = macroRegex.search(line)
        if None == mo:
            continue
        #print(mo.groups())
        macroDict[mo.group(1)] = mo.group(2)
    return macroDict; 

def ReadTargetOption():
    macroList = ''
    return macroList


def ReadFeaturesLog():
    macroList = ''
    return macroList;

#currentPath = os.getcwd()
#print('#'*30 + '\n' + currentPath + '\n' + '#'*30)

#macros = ReadMakeFile2('TEST_GPRS.mak')
#print(macros['RVCT_VERSION'])
#print('Read macro number: ' + str(len(macros.keys())))

#ReadMakeFile2('TEST_GPRS.mak')
