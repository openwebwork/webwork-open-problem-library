import os
import re

path = os.getcwd()

filelist = []
for filename in os.listdir(path):
    if filename[-3:] == '.pg':
        filelist.append(filename)


    else:
        pass

count_files = 0

for files in filelist: 
    print("Working on: " +files)






    count_files += 1

    chapter_flag = 0
    section_flag = 0
    date_flag = 0
    level_flag = 0 
    keyword_flag = 0 
    resources_flag = 0




# Script written to modify the headers for the files which were found in contrib and pending
# this one is still a prototyep and is currently being developed and tested


    with open(files) as getHeaders:
        contents = getHeaders.read()
        pattern = re.compile(r'DBsubject\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(contents)

        for match in matches: 
            local_DBsubject = match.group(1)
            
        
        pattern = re.compile(r'DBchapter\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(contents)

        for match in matches: 
            local_DBchapter = match.group(1)
            chapter_flag = 1
        if chapter_flag == 1:
            pass
        else: 
            local_DBchapter = ""
            print('local_DBchapter in ' + files + '\n')
            

        pattern = re.compile(r'DBsection\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(contents)

        for match in matches: 
            local_DBsection = match.group(1)
            section_flag = 1
        if section_flag == 1:
            pass
        else: 
            local_DBsection = ""
            print('local_DBsection in ' + files + '\n')
            
        
        pattern = re.compile(r'Date\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(contents)

        for match in matches: 
            local_Date = match.group(1)
            date_flag = 1
        if date_flag == 1:
            pass
        else: 
            local_Date = ""
            print('local_Date in ' + files + '\n')
            


        pattern = re.compile(r'Level\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(contents)

        for match in matches: 
            local_Level = match.group(1)
            level_flag = 1
        if level_flag == 1:
            pass
        else: 
            local_level = ''
            local_Level = ""
            print('local_level in ' + files + '\n')
            

        pattern = re.compile(r'KEYWORDS\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(contents)

        for match in matches: 
            local_KEYWORDS = match.group(1)
            keyword_flag = 1
        if keyword_flag == 1:
            pass
        else: 
            local_KEYWORDS = ""
            print('local_KEYWORDS in ' + files + '\n')
            

        pattern = re.compile(r'RESOURCES\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(contents)

        for match in matches: 
            local_RESOURCES = match.group(1)
            resources_flag = 1
        if resources_flag == 1:
            pass
        else: 
            local_RESOURCES = ""
            print('local_RESOURCES in ' + files + '\n')
            




    with open(files) as original_file:
        contents = original_file.read()

        pattern = re.compile(r'DOCUMENT\(\)')
        matches = pattern.finditer(contents)

        for match in matches:
            start_index = match.start()
            
            break

        local_question_content = contents[start_index:] # obtain the rest of the question (below the header)



    with open('Derivatives2017Headerformat.txt') as newHeader:
        local_new_header = newHeader.read()

        pattern = re.compile(r'DBsubject\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(local_new_header)

        for match in matches: 
            DBsubject_index = match.start()
            local_new_header = local_new_header[:DBsubject_index+10] + local_DBsubject + local_new_header[DBsubject_index+10:]
        

        pattern = re.compile(r'DBchapter\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(local_new_header)

        for match in matches: 
            DBchapter_index = match.start()
            local_new_header = local_new_header[:DBchapter_index+10] + local_DBchapter + local_new_header[DBchapter_index+10:]



        pattern = re.compile(r'DBsection\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(local_new_header)

        for match in matches: 
            DBsection_index = match.start()
            local_new_header = local_new_header[:DBsection_index+10] + local_DBsection + local_new_header[DBsection_index+10:]
        
        pattern = re.compile(r'Date\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(local_new_header)

        for match in matches: 
            Date_index = match.start()
            local_new_header = local_new_header[:Date_index+5] + local_Date + local_new_header[Date_index+5:]


        pattern = re.compile(r'Level\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(local_new_header)

        for match in matches: 
            Level_index = match.start()
            local_new_header = local_new_header[:Level_index+6] + local_Level + local_new_header[Level_index+6:]

        pattern = re.compile(r'KEYWORDS\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(local_new_header)

        for match in matches: 
            KEYWORDS_index = match.start()
            local_new_header = local_new_header[:KEYWORDS_index+9] + local_KEYWORDS + local_new_header[KEYWORDS_index+9:]

        pattern = re.compile(r'RESOURCES\(([\' /:,a-zA-Z0-9_.+ -]*)\)') # what we are looking to get
        
        matches =  pattern.finditer(local_new_header)

        for match in matches: 
            RESOURCES_index = match.start()
            local_new_header = local_new_header[:RESOURCES_index+10] + local_RESOURCES + local_new_header[RESOURCES_index+10:]





    if os.path.isdir('New Files') == True: # check if we need to create a new folder
        pass
    else:
        os.mkdir('New Files')

    os.chdir('New Files') # change to the new folder

    with open(files, 'w') as new_file:
        new_file.write(local_new_header)
        new_file.write(local_question_content)

    os.chdir("..")


print("Processed " + str(count_files) + " files ") 
