# %%

#Description:
# Creates the .def file for the problems in the current folder
# Adds all files to a .tar.gz archive

import os
import fileinput
import shutil

cwd = os.getcwd()
currentfolder = cwd.split("\\")[-1]
directory = os.listdir(os.getcwd())

FolderName = input("What be the folder name?")

header = """setNumber=Chapter2_UBC_OER_Mechanics
openDate = 1/7/00 at 6:00am
dueDate = 1/20/09 at 6:00am
answerDate = 1/21/09 at 6:00
paperHeaderFile = defaultHeader
screenHeaderFile = defaultHeader
problemList =\n"""

content = ""

for filename in directory:
    if filename.endswith('.pg'):
        content += FolderName + '/' + filename + ', 1\n'

content = header + content
f = open('set_'+FolderName+'.def','w', encoding='utf-8')  #create new file
f.write(content)              #write to fole
f.close()
# %%
import tarfile

current_dir = os.path.basename(os.getcwd())

with tarfile.open(current_dir+'.tar.gz', 'w:gz') as archive:
    archive.format = tarfile.GNU_FORMAT
    for i in os.listdir():
        if i.endswith('.pg') or i.endswith('.png') or i.endswith('.pdf'):
            archive.add(i)