import getentities as mtbl
from helperclasses.entities import flag,keyvalpair,tempref,errlis,categorycollection, \
    NO_DESCRIPTION, NO_KEYNAME, NO_TYPE, NO_EXTRA, NO_IMG_ALT, PREDICTED_FLAG_VAL
import re

# TO-DO: Keep reference and other links

mainelementtag = "div"
mainelementclass = "mw-parser-output"
contentheaderclass = "mw-headline"
collapsed_desc_class = "mw-collapsible"
collapsed_desc_class_inner = "mw-collapsible-content"
descriptiontag = "p"

navstrtyp = "<class 'bs4.element.NavigableString'>"
tagtyp = "<class 'bs4.element.NavigableString'>"

keyvalreg = re.compile("(.*)\((.+)\)\s+<(.+)>\s*(.*)")
backupkvreg = re.compile("(.*)\s+<(.+)>\s*(.*)")
keyval_descdictpattern = re.compile("(\d+)\s*(?:\.|\:)\s*(.*)")

cattbl = mtbl.categories

# Debug
enable_cat = False
enable_limit = False
enable_index = False

LIMITCALL = 1
testindex = 3

cattest = "weapon"
if enable_cat:
    cattbl = dict()
    cattbl[cattest] = mtbl.categories[cattest]

print_desc = False
print_flags = False
print_kvs = False

print_sqt = False

print_err = True
#######

def getTextFromTag(tag):
    s = ""
    for ch in tag.children:
        s += getTextFromChildrenTag(ch)
    return s

def getTextFromChildrenTag(ch):
    ctyp = str(type(ch))
    if ch.name == "img":
        if ch.get_attribute_list("alt")[0] is not None:
            if any([(extension in ch['alt']) for extension in [".png",".jpg",".jpeg",".bmp",".ico"]]):
                return "" 
            return ch['alt'].replace("<","[").replace(">","]").replace("(","[").replace(")","]")
        else:
            return NO_IMG_ALT
    if ctyp == navstrtyp:
        return ch.string
    elif ctyp == tagtyp:
        return ch.text
    else:
        return getTextFromTag(ch)

# TO-DO: Add keyval categories
def __handlekvpairtag(descch,foundkvs,desc_continues,ent,errorlist=errlis()):
    while descch.ref is not None: #dl->dt,dd
        typ = str(type(descch.ref))
        if typ == navstrtyp:
            if descch.ref.string.strip() not in [None,""]:
                errorlist.lis.append("navstr:" + descch.ref.string.strip())
            descch.ref = descch.ref.find_next_sibling()
            continue

        if descch.ref.name == "dt" or descch.ref.name == "b":
            fulltxt = getTextFromChildrenTag(descch.ref)
            desc_continues = False
            #print(fulltxt)
            matchtitle = keyvalreg.search(fulltxt)
            if matchtitle is None:
                matchtitle = backupkvreg.search(fulltxt)
                if matchtitle is None:
                    #print("No match for kv: "+fulltxt)
                    foundkvs.append(keyvalpair([fulltxt,NO_KEYNAME,NO_TYPE,NO_EXTRA]))
                else:
                    #print("Backup match for kv: "+fulltxt)
                    shortinfo = matchtitle.groups()[0].strip()
                    valtyp = matchtitle.groups()[1].strip()
                    extr = matchtitle.groups()[2].strip()
                    foundkvs.append(keyvalpair([shortinfo,NO_KEYNAME,valtyp,extr]))

                descch.ref = descch.ref.find_next_sibling()
                continue
            else:
                shortinfo = matchtitle.groups()[0].strip()
                keyname = matchtitle.groups()[1].strip()
                valtyp = matchtitle.groups()[2].strip()
                extr = matchtitle.groups()[3].strip()
                descch.ref = descch.ref.find_next_sibling()
                foundkvs.append(keyvalpair([shortinfo,keyname,valtyp,extr]))
                #print(shortinfo + " ("+keyname+") <"+valtyp+">")

        elif descch.ref.name == "dd":
            fulltxt = getTextFromChildrenTag(descch.ref)
            if len(foundkvs) == 0:
                errorlist.lis.append("No parent kvpair for descripion: "+fulltxt)
            elif desc_continues:
                foundkvs[-1].description += "\n"+fulltxt
            else:
                desc_continues = True
                foundkvs[-1].description = fulltxt
            descch.ref = descch.ref.find_next_sibling()

        elif descch.ref.name == "div":
            desc_continues = False
            #print(descch.ref["class"])
            if collapsed_desc_class_inner in descch.ref["class"] \
                or collapsed_desc_class in descch.ref["class"]:
                dicttext = getTextFromChildrenTag(next(descch.ref.children))
                #print(dicttext)
                for r in dicttext.split("\n"):
                    if(r.strip() == ""):
                        continue
                    matchs = keyval_descdictpattern.search(r)
                    if matchs is None:
                        errorlist.lis.append(ent.name+": Bad kv choice split: "+ r)
                    else:
                        foundkvs[-1].descriptiondict[matchs.groups()[0].strip()] = matchs.groups()[1].strip()

                descch.ref = descch.ref.parent.find_next_sibling()
            else:
                #print("before div:"+str(len(foundkvs)))
                foundkvs = readkvpairs(tempref(next(descch.ref.children)),foundkvs,ent=ent)
                #print("after div:"+str(len(foundkvs)))
                descch.ref = descch.ref.find_next_sibling()

        elif descch.ref.name == "dl":
            desc_continues = False
            #print("before dl:"+str(len(foundkvs)))
            foundkvs = __handlekvpairtag(tempref(next(descch.ref.children)),foundkvs,desc_continues,ent,errorlist=errorlist)
            #print("after dl:"+str(len(foundkvs)))
            descch.ref = descch.ref.find_next_sibling()

        else:
            fulltxt = getTextFromChildrenTag(descch.ref)
            if descch.ref.name == "p":
                desc_continues = False
            elif descch.ref.name == "strong":
                if len(foundkvs) == 0:
                    ent.kvpairnotestypes.append(fulltxt)
                else: 
                    foundkvs[-1].notetypes.append(fulltxt)
            elif descch.ref.name == "span":
                if len(foundkvs) == 0:
                    ent.kvpairnotesvals.append(fulltxt)
                else: 
                    foundkvs[-1].notevals.append(fulltxt)
            elif descch.ref.name == "ul":
                d = dict()
                for r in fulltxt.split("\n"):
                    if(r.strip() == ""):
                        continue
                    matchs = keyval_descdictpattern.search(r)
                    if matchs is None:
                        errorlist.lis.append(ent.name+": Bad kv choice split: "+ r)
                    else:
                        d[matchs.groups()[0].strip()] = matchs.groups()[1].strip()

                foundkvs[-1].descriptiondict = d
            elif descch.ref.name == "h2":
                return foundkvs
            else:
                errorlist.lis.append(_catname + "->" +ent.name+" : DIDNT HANDLE <"+descch.ref.name+"> : "+fulltxt)
            descch.ref = descch.ref.find_next_sibling()
    return foundkvs

def readkvpairs(desctagtrail,foundkvs,ent,errorlist=errlis()):
    desctagtrail.ref = desctagtrail.ref.find_next_sibling()

    if desctagtrail.ref is None:
        return foundkvs

    if desctagtrail.ref.name == "p":
        desctagtrail.ref = desctagtrail.ref.find_next_sibling()
    
    if desctagtrail.ref is None:
        return foundkvs
    #print(desctagtrail.ref)
    while desctagtrail.ref.name == "dl" or desctagtrail.ref.name == "div":
        if desctagtrail.ref is None:
            errorlist.lis.append("No kv list...")
            return foundkvs
        
        descch = desctagtrail.ref.children
        if descch is None:
            errorlist.lis.append("No description children")
            return foundkvs

        descch = tempref(next(descch))

        foundkvs = __handlekvpairtag(descch,foundkvs,False,ent,errorlist=errorlist)
        
        nextc = tempref(desctagtrail.ref.find_next_sibling())
        if nextc.ref is None:
            return foundkvs

        if nextc.ref.name == "h2":
            #print("Header next...")
            return foundkvs
        
        return readkvpairs(desctagtrail,foundkvs,ent=ent,errorlist=errorlist)
    
    return foundkvs

def __readflagsfromchildren(desctagtrail,flags,errorlist=errlis(),flagcategory=""):
    for flgch in desctagtrail:
        flg = getTextFromChildrenTag(flgch)
        #print(flg)
        if(str(type(flgch)) == navstrtyp):
            if flgch.string.strip() in [None,""]:
                continue
            errorlist.lis.append(ent.name+" navstr: "+flgch.string.strip())
            continue
        splt = flg.split(":")
        if len(splt) == 2:
            flags.append(flag(splt[0],splt[1],cat=flagcategory))
            #print(flags[-1].printstr())
        elif len(splt) > 2:
            flags.append(flag(splt[0],"\t".join([splt[i] for i in range(1,len(splt))]),cat=flagcategory))
        else:
            flags.append(flag(str(2**len(flags)),flg,cat=flagcategory))
            flags[-1].description += PREDICTED_FLAG_VAL
    return flags

def readflags(desctagtrail,flagcategory,flags,ent,errorlist=errlis()):
    while desctagtrail.ref is not None and desctagtrail.ref.name == "ul":
        __readflagsfromchildren(desctagtrail.ref.children,flags,errorlist=errorlist,flagcategory=flagcategory)
        #print(flags)
        nextc = desctagtrail.ref.find_next_sibling()
        skip = True
        if nextc is None:
            desctagtrail.ref = nextc
            break
        elif nextc.name == "h2":
            desctagtrail.ref = nextc
            break
        elif nextc.name == "ul":
            skip = False
        else:
            desc_continues = True
            while nextc.name != "ul":
                fulltxt = getTextFromChildrenTag(nextc).strip()
                #print(nextc.name + " -> " + fulltxt)
                if nextc.name == "h2":
                    desctagtrail.ref = nextc
                    break
                elif nextc.name == "p":
                    flagcategory = fulltxt
                    desc_continues = False
                elif nextc.name == "dl":
                    if len(flags) == 0:
                        ent.flagnotestypes.append("Details:")
                        ent.flagnotesvals.append(fulltxt)
                    else:    
                        flags[-1].notetypes.append("Details:")
                        flags[-1].notevals.append(fulltxt)
                    desc_continues = False
                elif nextc.name == "strong":
                    if len(flags) == 0:
                        ent.flagnotestypes.append(fulltxt)
                    else:    
                        flags[-1].notetypes.append(fulltxt)
                elif nextc.name == "span":
                    if len(flags) == 0:
                        ent.flagnotesvals.append(fulltxt)
                    else: 
                        flags[-1].notevals.append(fulltxt)
                elif nextc.name == "div":
                    for s in nextc.children:
                        if s.name == "strong":
                            if len(flags) == 0:
                                ent.flagnotestypes.append(getTextFromChildrenTag(s))
                            else: 
                                flags[-1].notetypes.append(getTextFromChildrenTag(s))
                        elif s.name == "span":
                            if len(flags) == 0:
                                ent.flagnotesvals.append(getTextFromChildrenTag(s))
                            else: 
                                flags[-1].notevals.append(getTextFromChildrenTag(s))
                else:
                    errorlist.lis.append(_catname+"->"+ent.name+" : "+"DIDNT HANDLE <"+nextc.name+"> : "+fulltxt)

                nextc = nextc.find_next_sibling()
                if nextc is None or not desc_continues:
                    desctagtrail.ref = nextc
                    break
            skip = False

        if skip:
            break

        desctagtrail.ref = nextc
    return flags

errors = errlis()

i = 0
for _catname,cat in cattbl.items():
    print("///////////////////////////////////////////////")
    print("CATEGORY: "+_catname)
    print("///////////////////////////////////////////////")

    for idx in range(len(cat.entities)):
        if enable_index:
            idx = testindex
        ent = cat.entities[idx]
        print("++++++++++++++++++++++++++++++++++++++++++")
        print("ENTITY: "+ent.name)
        print("++++++++++++++++++++++++++++++++++++++++++")
        try:
            soup = mtbl.BeautifulSoup(mtbl.getPageContent(ent.link),features="html.parser")
        except:
            ent.description = NO_DESCRIPTION
            #print(NO_DESCRIPTION)
            continue

        maintbl = soup.find(mainelementtag,{"class":mainelementclass})
        description = ""

        for childtag in maintbl.children:
            chtyp = str(type(childtag))
            if childtag.name == "h2": # Description ends
                break

            if chtyp != navstrtyp \
                and childtag.get_attribute_list("id")[0] is not None \
                    and childtag['id'] == "toc": # table of content skip
                continue

            if childtag.name == "p":
                description += getTextFromTag(childtag)
        
        if description.strip() == "":
            description = NO_DESCRIPTION
            ent.description = description
            continue

        ent.description = description
        if print_desc:
            print(description)

        desctagtrail = None
        # contents
        for title in soup.find_all("span",{"class":contentheaderclass}):
            desctagtrail = title.parent
            if title.string is None:
                continue
            headertxt = title.string.lower().strip()
            #print(headertxt)
            #flags
            if headertxt == "flags":
                flags = list()
                flagcategory = ""
                desctagtrail = desctagtrail.find_next("ul")
                flagcategory = ""

                desctagtrail = tempref(desctagtrail)
                flags = readflags(desctagtrail,flagcategory,flags,ent,errorlist=errors)
                desctagtrail = desctagtrail.ref

                ent.flags = sorted(flags,key=lambda f:f.val)
                
                if print_flags:
                    print("----FLAGS")
                    for j in range(len(ent.flags)):
                        print(ent.flags[j].printstr())
                
            #keyvals
            elif headertxt in ["keyvalues","key-values","key values"]:
                foundkvs = readkvpairs(tempref(desctagtrail),list(),ent=ent,errorlist=errors)
                
                if print_kvs:
                    print("----KVPAIRS")
                    for j in range(len(foundkvs)):
                        print(foundkvs[j].printstr())
                        print("")
                    
                ent.kvpairs = foundkvs
            # TO-DO: Add inputs/outputs and other descriptive sections
            elif headertxt == "inputs":
                pass
            elif headertxt == "outputs":
                pass
            else: # See also, Uses, Custom description etc
                print(desctagtrail)
        #print("")
        i += 1
        if i >= LIMITCALL and enable_limit:
            break

    print("")
    if i >= LIMITCALL and enable_limit:
        break

if print_err:
    for e in errors.lis:
        print(e)

    print(len(errors.lis))

allents = categorycollection(cattbl)
if print_sqt:
    print(allents.sqtable())

filedir = "./2229460523/scripts/vscripts/resource_tables/entitydetailtables.nut"

writetofile = input("Write to file (Y/N)? ")
if str(writetofile).lower() == "y":
    with open(filedir, "w") as entfile:
        print("::EntityDetailTables <- \n" + allents.sqtable(),file=entfile)

input("\nPress any key to quit...")