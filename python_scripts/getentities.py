from bs4 import BeautifulSoup
from urllib import request
from helperclasses.entities import category,entity

def getPageContent(_url):
    con = request.urlopen(request.Request(_url, headers={'User-Agent' : "Magic Browser"} ) )
    return con.read()

def validateLink(ent):
    if ent.link.find("&redlink=1") != -1:
        ent.linkvalid = False

baseurl = "https://developer.valvesoftware.com"
url = baseurl+"/wiki/List_of_L4D2_Entities"

contenttabletag = "div"
contenttablestyle = "column-count: 4; -moz-column-count: 4; -webkit-column-count: 4;"

categorytitletag = "h4"
categoryentitylisttag = "ul"
categoryentitylisttaginner = "li"


categories = dict()

soup = BeautifulSoup(getPageContent(url),features="html.parser")
entcount = 0
for currentfgd in soup.find_all(contenttabletag, {"style":lambda x: contenttablestyle in x if x is not None else False}):
    currcatlist = currentfgd.find_all(categorytitletag)
    currentlist = currentfgd.find_all(categoryentitylisttag)
    for i in range(min(len(currentlist),len(currcatlist))):
        currentcategory = currcatlist[i]
        currentlis = currentlist[i]
        #print("cat:"+currentcategory.string)
        cat = category(currentcategory.string)
        ents = []
        for currentent in currentlis.find_all(categoryentitylisttaginner):
            if currentent.string is None:
                currentent = currentent.find("a",href=True)
                e = entity(currentent.string,baseurl+currentent['href'],currentent.get('title'))

                validateLink(e)
                ents.append(e)

                entcount += 1
                continue

            anc = currentent.find("a",href=True)
            e = entity(currentent.string,baseurl+anc['href'],anc.get('title'))

            validateLink(e)
            ents.append(e)
            
            entcount += 1

        #print(cat.printstr())
        if currentcategory.string in categories.keys():
            categories[cat.prefix].entities.extend(ents)
        else:
            cat.entities = ents
            categories[cat.prefix] = cat

print("Category count: "+str(len(categories)))
print("Entity count: "+str(entcount))

#testcategory = "info"
#print("Category "+testcategory+" entities:")
#print(categories[testcategory].printstr())

#input("\nPress any key to quit...")

