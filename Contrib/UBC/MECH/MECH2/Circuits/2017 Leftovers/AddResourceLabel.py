import os
import re
import shutil

folderName = "newPGs"

#directory for converted files
if not os.path.exists(folderName): 
    os.makedirs(folderName)
else:
	shutil.rmtree(folderName) #remove old directory
	os.makedirs(folderName)

cwd = os.getcwd(); #current working directory
directory = os.listdir(os.getcwd());
fileList = list();

for filename in directory:
    if (filename.endswith(".pg")):
        fileList.append(filename);
		
print("{} .pg files found.".format(len(fileList)));



for file in fileList:
	f = open(file,"r");
	
	try:
		content = f.read();

		imageMatches = re.findall('image\(.*?\"(.*?)\".*?\)',content)
		resourceTags = re.findall('##\s*?RESOURCES\([\"\'].*?[\"\']\)', content)

		if imageMatches is not None and (len(imageMatches) > 0):

			if ((resourceTags is not None) and (len(resourceTags) > 0)): #if resources tag exists, remove it to add it back later
				for resourceTag in resourceTags:
					content = content.replace(resourceTag+"\n", "", 1)

			imageText=""
			while len(imageMatches)>0:
				imageText+= "\'"+imageMatches.pop(0)+"\'"
				if len(imageMatches)!=0:
					imageText+=', '

			keywordsTag = re.findall('##\s*?KEYWORDS\(.*?\)', content)

			if len(keywordsTag)>0:
				content = content.replace(keywordsTag[0]+"\n", keywordsTag[0] + "\n## RESOURCES("+imageText+")\n",1)
			else:
				descriptionTag = re.findall('##\s*?ENDDESCRIPTION', content)
				if len(descriptionTag)>0:
					content = content.replace(descriptionTag[0], descriptionTag[0] + "\n\n## RESOURCES("+imageText+")\n",1)
				else:
					content = "## RESOURCES("+imageText+")\n" + content

			newPG = open(folderName + "\\" + file, "w");
			newPG.write(content);
			newPG.close();
		
		else:
			f.close();
			continue;

	except:
		pass

	f.close();
