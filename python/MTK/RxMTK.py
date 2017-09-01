#/usr/bin/python
import os
import re
<<<<<<< HEAD
import shutil 
import time

def GetDateTime():
    dt = time.localtime()
    return "%d-%02d-%02d %02d:%02d" % (dt.tm_year, dt.tm_mon, dt.tm_mday, dt.tm_hour, dt.tm_min)

def ReadFileLines(fileName):
    fileBuffer = []
    if not os.path.exists(fileName):
        print(fileName + ' not exists!!!\n')
    try:
        hdl = open(fileName)
        try:
            fileBuffer = hdl.readlines()
        finally:
            hdl.close()
    except:
        print(fileName + ' read file fail!!!')
    return fileBuffer

def ParseMakeFile(makeName):
    makeFile = os.path.join('make', makeName)
    macroDict = dict()
    for line in ReadFileLines(makeFile):
=======

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
>>>>>>> 2d5370e5a087492cb4ac7c2981853ddaaa22f6a1
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

<<<<<<< HEAD
def ParseTargetOption():
    macroList = ''
    return macroList

#MMI_features.log
def ParseFeaturesLog(logFile):
    macros = []
    for line in ReadFileLines(logFile):
        line = line.strip()
        if len(line) > 3 and line[:3] == '[D]':
            macros.append(line[3:])
    return macros

def ParseMakeIni(iniFile):
    #print('Parse ' + iniFile)
    macroDict = dict()
    for line in ReadFileLines(iniFile):
        line = line.strip()
        array = line.split('=')
        if len(array) != 2 or 0 == len(array[1]): 
            continue
        key = array[0].strip()
        value = array[1].strip()
        macroDict[key] = value
        #print(key, value)
    return macroDict

def PackageBin(custom, project, verno, target):
    #print("package files:")
    path = os.path.join('build', custom)
    if not os.path.exists(path):
        exit(0)
    #macros = ParseMakeFile(custom+'_'+project+".mak")
    #if 'PLATFORM' not in macros.keys() or \
    #    'CHIP_VER' not in macros.keys():
    #    return 
    #platform = macros['PLATFORM']
    #chip_ver = macros['CHIP_VER']
    dt = time.localtime()
    dtStr = "%02d%02d%02d%02d" % (dt.tm_mon, dt.tm_mday, dt.tm_hour, dt.tm_min)
    target = os.path.join(target, custom + verno) + '[' + dtStr + ']'
    if os.path.exists(target):
        print('Folder exist!!!')
        exit(-1)
    os.mkdir(target)
    for f in os.listdir(path):
        if (project in f) and (f[-4:] in ['.bin', '.lis', '.elf', '.sym']):
            print(f)
        elif ('DbgInfo_' in f) and (verno in f):
            print(f)
        else:
            continue
        src = os.path.join(path, f)
        dst = os.path.join(target, f)
        if os.path.isdir(src):
            shutil.copytree(src, dst)
        else:
            shutil.copy(src, dst)
    #file = 'BPLGUInfoCustomAppSrcP_' + platform + chip_ver + verno
    path = os.path.join('tst', 'database_classb')
    for f in os.listdir(path):
        if 'BPLGUInfoCustomAppSrcP_' in f and verno in f:
            print(f)
            src = os.path.join(path, f)
            dst = os.path.join(target, f)
            shutil.copy(src, dst)
            break
    print('\ncopy %d files' % len(os.listdir(target)))

def GetMtkRoot(path):
    for f in os.listdir(path):
        f = os.path.join(path, f)
        if os.path.isdir(f) and os.path.exists(os.path.join(f, 'make.bat')) :
            return f
    return ''

if __name__ == "__main__":
    print('-'*80)
    basePath = os.getcwd()
    if not os.path.exists('make.bat'):
        os.chdir('..')
        newPath = GetMtkRoot('.')
        if '' == newPath:
            print('Can not find MTK project path!\n')
            exit(-1)
        newPath = os.path.abspath(newPath)
        os.chdir(newPath)
    print(os.getcwd())
    iniInfo = ParseMakeIni('make.ini')
    if 'custom' not in iniInfo.keys():
        exit(-1)
    custom = iniInfo['custom']
    project = iniInfo['project']

    targetPath = os.path.join(basePath, '..', 'backup')
    targetPath = os.path.abspath(targetPath)
    PackageBin(custom, project, 'TR00GT_V00_170823', targetPath)
=======
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
>>>>>>> 2d5370e5a087492cb4ac7c2981853ddaaa22f6a1
