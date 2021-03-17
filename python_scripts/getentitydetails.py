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

inputreg = re.compile("(.+)\s+<(.+)>\s*(.*)")
backupinputreg = re.compile("(.+)\s+\s*(.*)")

outputreg = re.compile("(On.+)\s+\s*(.*)")
backupoutputreg = re.compile("(.+)\s*(.*)")

cattbl = mtbl.categories

# Debug
enable_cat = False
enable_entity = False
enable_index = False
enable_limit = False

cattest = "func"
enttest = "func_physbox"

if enable_cat:
    cattbl = dict()
    cattbl[cattest] = mtbl.categories[cattest]

print_desc = False
print_flags = False
print_kvs = False
print_ins = False
print_outs = False

print_sqt = False

print_err = True

LIMITCALL = 1
testindex = 0
if enable_entity:
    chosencat = cattbl[cattest].entities
    for idx in range(len(chosencat)):
        if chosencat[idx].name == enttest:
            testindex = idx
            break
#######

def getTextFromTag(tag):
    if tag is None:
        return ""
    s = ""
    for ch in tag.children:
        s += getTextFromChildrenTag(ch)
    return s

def getTextFromChildrenTag(ch):
    if ch is None:
        return ""
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
def __handlekvpairtag(descch,foundkvs,desc_continues,ent,errorlist=errlis(),kvtype="keyvals"):
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
            if kvtype == "keyvals":
                matchtitle = keyvalreg.search(fulltxt)
                if matchtitle is None:
                    matchtitle = backupkvreg.search(fulltxt)
                    if matchtitle is None:
                        #print("No match for kv: "+fulltxt)
                        foundkvs.append(keyvalpair([fulltxt,NO_KEYNAME,NO_TYPE,NO_EXTRA],kvtype=kvtype))
                    else:
                        #print("Backup match for kv: "+fulltxt)
                        shortinfo = matchtitle.groups()[0].strip()
                        valtyp = matchtitle.groups()[1].strip()
                        extr = matchtitle.groups()[2].strip()
                        foundkvs.append(keyvalpair([shortinfo,NO_KEYNAME,valtyp,extr],kvtype=kvtype))

                    descch.ref = descch.ref.find_next_sibling()
                    continue
                else:
                    shortinfo = matchtitle.groups()[0].strip()
                    keyname = matchtitle.groups()[1].strip()
                    valtyp = matchtitle.groups()[2].strip()
                    extr = matchtitle.groups()[3].strip()
                    descch.ref = descch.ref.find_next_sibling()
                    foundkvs.append(keyvalpair([shortinfo,keyname,valtyp,extr],kvtype=kvtype))
                    #print(shortinfo + " ("+keyname+") <"+valtyp+">")
            elif kvtype == "inputs":
                matchtitle = inputreg.search(fulltxt)
                if matchtitle is None:
                    matchtitle = backupinputreg.search(fulltxt)
                    if matchtitle is None:
                        #print("No match for kv: "+fulltxt)
                        foundkvs.append(keyvalpair(["",fulltxt,NO_TYPE,NO_EXTRA],kvtype=kvtype))
                    else:
                        #print("Backup match for kv: "+fulltxt)
                        keyname = matchtitle.groups()[0].strip()
                        valtyp = matchtitle.groups()[1].strip()
                        foundkvs.append(keyvalpair(["",keyname,valtyp,NO_EXTRA],kvtype=kvtype))

                    descch.ref = descch.ref.find_next_sibling()
                    continue
                else:
                    keyname = matchtitle.groups()[0].strip()
                    valtyp = matchtitle.groups()[1].strip()
                    extr = matchtitle.groups()[2].strip()
                    descch.ref = descch.ref.find_next_sibling()
                    foundkvs.append(keyvalpair(["",keyname,valtyp,extr],kvtype=kvtype))
                    #print(shortinfo + " ("+keyname+") <"+valtyp+">")
            elif kvtype == "outputs":
                matchtitle = outputreg.search(fulltxt)
                if matchtitle is None:
                    matchtitle = backupoutputreg.search(fulltxt)
                    if matchtitle is None:
                        #print("No match for kv: "+fulltxt)
                        foundkvs.append(keyvalpair(["",fulltxt,NO_TYPE,NO_EXTRA],kvtype=kvtype))
                    else:
                        #print("Backup match for kv: "+fulltxt)
                        keyname = matchtitle.groups()[0].strip()
                        valtyp = matchtitle.groups()[1].strip()
                        foundkvs.append(keyvalpair(["",keyname,valtyp,NO_EXTRA],kvtype=kvtype))

                    descch.ref = descch.ref.find_next_sibling()
                    continue
                else:
                    keyname = matchtitle.groups()[0].strip()
                    extr = matchtitle.groups()[1].strip()
                    descch.ref = descch.ref.find_next_sibling()
                    foundkvs.append(keyvalpair(["",keyname,"",extr],kvtype=kvtype))
                    #print(shortinfo + " ("+keyname+") <"+valtyp+">")

        elif descch.ref.name == "dd":
            fulltxt = getTextFromChildrenTag(descch.ref)
            if len(foundkvs) == 0:
                errorlist.lis.append("No parent kvpair("+kvtype+") for description: "+fulltxt)
            elif desc_continues:
                foundkvs[-1].description += "\n"+fulltxt
            else:
                desc_continues = True
                foundkvs[-1].description = fulltxt
            descch.ref = descch.ref.find_next_sibling()

        elif descch.ref.name == "div":
            desc_continues = False
            #print(descch.ref["class"])
            if descch.ref.has_attr("class") and (collapsed_desc_class_inner in descch.ref["class"] \
                or collapsed_desc_class in descch.ref["class"]):
                dicttext = getTextFromChildrenTag(next(descch.ref.children,None))
                #print(dicttext)
                for r in dicttext.split("\n"):
                    if(r.strip() == ""):
                        continue
                    matchs = keyval_descdictpattern.search(r)
                    if matchs is None:
                        errorlist.lis.append(ent.name+", "+kvtype+": Bad kv choice("+kvtype+") split: "+ r)
                    else:
                        knm = matchs.groups()[0].strip()
                        if knm in foundkvs[-1].descriptiondict:
                            foundkvs[-1].descriptiondict[knm] += ".\r" + matchs.groups()[1].strip()
                        else:
                            foundkvs[-1].descriptiondict[knm] = matchs.groups()[1].strip()

                descch.ref = descch.ref.parent.find_next_sibling()
            else:
                #print("before div:"+str(len(foundkvs)))
                foundkvs = readkvpairs(tempref(next(descch.ref.children,None)),foundkvs,ent=ent,errorlist=errorlist,kvtype=kvtype)
                #print("after div:"+str(len(foundkvs)))
                descch.ref = descch.ref.find_next_sibling()

        elif descch.ref.name == "dl":
            desc_continues = False
            #print("before dl:"+str(len(foundkvs)))
            foundkvs = __handlekvpairtag(tempref(next(descch.ref.children,None)),foundkvs,desc_continues,ent,errorlist=errorlist,kvtype=kvtype)
            #print("after dl:"+str(len(foundkvs)))
            descch.ref = descch.ref.find_next_sibling()

        else:
            fulltxt = getTextFromChildrenTag(descch.ref)
            if descch.ref.name == "p":
                desc_continues = False
            elif descch.ref.name == "strong":
                if len(foundkvs) == 0:
                    if kvtype == "keyvals":
                        ent.kvpairnotestypes.append(fulltxt)
                    elif kvtype == "inputs":
                        ent.inputnotestypes.append(fulltxt)
                    elif kvtype == "outputs":
                        ent.outputnotestypes.append(fulltxt)
                else: 
                    foundkvs[-1].notetypes.append(fulltxt)
            elif descch.ref.name == "span":
                if len(foundkvs) == 0:
                    if kvtype == "keyvals":
                        ent.kvpairnotesvals.append(fulltxt)
                    elif kvtype == "inputs":
                        ent.inputnotesvals.append(fulltxt)
                    elif kvtype == "outputs":
                        ent.outputnotesvals.append(fulltxt)
                else: 
                    foundkvs[-1].notevals.append(fulltxt)
            elif descch.ref.name == "ul" or descch.ref.name == "ol":
                d = dict()
                ccount = 1
                for r in fulltxt.split("\n"):
                    if(r.strip() == ""):
                        continue
                    matchs = keyval_descdictpattern.search(r)
                    if matchs is None:
                        if descch.ref.name == "ol":
                            d[str(ccount)] = r
                            ccount += 1
                        else: 
                            errorlist.lis.append(ent.name+", "+kvtype+": Bad kv choice split: "+ r)
                    else:
                        knm = matchs.groups()[0].strip()
                        if knm in d:
                            d[knm] += ".\r" + matchs.groups()[1].strip()
                        else:
                            d[knm] = matchs.groups()[1].strip()
                
                foundkvs[-1].descriptiondict = d
            elif descch.ref.name == "h2":
                return foundkvs
            else:
                errorlist.lis.append(_catname + "->" +ent.name+" ("+kvtype+"): DIDNT HANDLE <"+descch.ref.name+"> : "+fulltxt)
            descch.ref = descch.ref.find_next_sibling()
    return foundkvs

def readkvpairs(desctagtrail,foundkvs,ent,errorlist=errlis(),kvtype="keyvals"):
    if desctagtrail.ref is None:
        return foundkvs

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
            errorlist.lis.append("No kv list for "+kvtype+"...")
            return foundkvs
        
        descch = desctagtrail.ref.children
        if descch is None:
            errorlist.lis.append("No description children")
            return foundkvs

        descch = tempref(next(descch, None))

        foundkvs = __handlekvpairtag(descch,foundkvs,False,ent,errorlist=errorlist,kvtype=kvtype)
        
        nextc = tempref(desctagtrail.ref.find_next_sibling())
        if nextc.ref is None:
            return foundkvs

        if nextc.ref.name == "h2":
            #print("Header next...")
            return foundkvs
        
        return readkvpairs(desctagtrail,foundkvs,ent=ent,errorlist=errorlist,kvtype=kvtype)
    
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
usedidx = False
for _catname,cat in cattbl.items():
    print("///////////////////////////////////////////////")
    print("CATEGORY: "+_catname)
    print("///////////////////////////////////////////////")

    if usedidx:
        break
    for idx in range(len(cat.entities)):
        if usedidx:
            break
        if enable_index:
            idx = testindex
            usedidx = True
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
                foundkvs = readkvpairs(tempref(desctagtrail),list(),ent=ent,errorlist=errors,kvtype="keyvals")
                
                if print_kvs:
                    print("----KVPAIRS")
                    for j in range(len(foundkvs)):
                        print(foundkvs[j].printstr())
                        print("")
                    
                ent.kvpairs = foundkvs

            # TO-DO: Add inputs/outputs and other descriptive sections
            elif headertxt == "inputs":
                foundins = readkvpairs(tempref(desctagtrail),list(),ent=ent,errorlist=errors,kvtype="inputs")
                
                if print_ins:
                    print("----INPUTS")
                    for j in range(len(foundins)):
                        print(foundins[j].printstr())
                        print("")
                    
                ent.inputs = foundins

            elif headertxt == "outputs":
                foundouts = readkvpairs(tempref(desctagtrail),list(),ent=ent,errorlist=errors,kvtype="outputs")
                
                if print_outs:
                    print("----OUTPUTS")
                    for j in range(len(foundouts)):
                        print(foundouts[j].printstr())
                        print("")
                    
                ent.outputs = foundouts
                
            elif headertxt != "see also":
                ent.description += "\n"+title.string.strip()+"\n"
                extras = ""
                while desctagtrail is not None and desctagtrail.find_next_sibling() is not None and desctagtrail.find_next_sibling().name != "h2":
                    desctagtrail = desctagtrail.find_next_sibling()
                    extras += getTextFromTag(desctagtrail) + "\n"
                ent.description += extras
                
        print("")
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
        print(("::EntityDetailTables <- \n" +allents.sqtable()).encode("ascii","ignore").decode("ascii"),file=entfile)

input("\nPress any key to quit...")