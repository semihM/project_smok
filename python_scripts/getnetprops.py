from bs4 import BeautifulSoup
from urllib import request

# TO-DO: Issue with parenting with same depth tables back-to-back

class classcollection:
    def __init__(self,tabledict=dict()):
        self.tables = tabledict

    def sqtable(self):
        s = "{\n\t"
        for classname,tbls in self.tables.items():
            s += classname + " = \n\t{\n\t\t"
            for depth,subtbls in tbls.tables.items():
                for subtbl in subtbls:
                    if "DT_" in subtbl.name:
                        for np in subtbl.members:
                            s += '"' + np.name.replace('"',"") + '" : \n\t\t{\n\t\t\t'
                            s += 'parentname = "' + subtbl.name + '"\n\t\t\t'
                            #s += 'fullname = "' + subtbl.printstrparented() + '"\n\t\t\t'
                            s += "depth = " + str(subtbl.depth) + "\n\t\t\t"
                            s += 'typ = "' + np.type + '"\n\t\t\t'
                            s += "offset = " + str(np.offset) + "\n\t\t\t"
                            s += "bits = " + str(np.bits) + "\n\t\t}\n\t\t"
                    else:
                        for np in subtbl.members:
                            s += '"' + subtbl.name + "." + np.name.replace('"',"") + '" : \n\t\t{\n\t\t\t'
                            s += 'parentname = "' + subtbl.parent.name + '"\n\t\t\t'
                            #s += 'fullname = "' + subtbl.printstrparented() + '"\n\t\t\t'
                            s += "depth = " + str(subtbl.depth) + "\n\t\t\t"
                            s += 'typ = "' + np.type + '"\n\t\t\t'
                            s += "offset = " + str(np.offset) + "\n\t\t\t"
                            s += "bits = " + str(np.bits) + "\n\t\t}\n\t\t"
            s += "\n\t}\n\t"
        s += "\n}"
        return s
    
class classtable:
    def __init__(self,name="",subtables={}):
        self.name = name
        self.tables = subtables
        self.depth = subtables.__len__()
        self.tablecount = sum([lis.__len__() for lis in self.tables.values()])
        self.membercount = sum([sum([subtbl.members.__len__() for subtbl in lis]) for lis in self.tables.values()])
    
    def gettable(self,tablename):
        i = 1
        length = self.tables.__len__()

        while i < length:
            for tbl in self.tables[i]:
                if tbl.name == tablename:
                    return tbl
            
            i += 1
        
        return None
    
    def getmember(self,membername,tablename=""):
        if tablename == "":
            i = 1
            length = self.tables.__len__()

            while i < length:
                for tbl in self.tables[i]:
                    member = tbl.getmember(membername)
                    if member is not None:
                        return member
                
                i += 1
            
            return None
        else:
            tbl = self.gettable(tablename)
            if tbl is None:
                return None
            else:
                return tbl.getmember(membername)
    
    def printbydepth(self,tblprefix="+",memberprefix="-"):
        for depth in self.tables.values():
            for tbl in depth:
                print(tbl.printstr(tblprefix) + " (Depth:"+ str(tbl.depth) + ")")
                for m in tbl.members:
                    print(m.printstr(memberprefix))

    def printbydepthfull(self,tblprefix="+",memberprefix="-"):
        for depth in self.tables.values():
            for tbl in depth:
                print(tbl.printstrfull(tblprefix) + " (Depth:"+ str(tbl.depth) + ")")
                for m in tbl.members:
                    print(m.printstrfull(memberprefix))
            
class subtable:
    def __init__(self,string,parent=None,members=[],clean=True,name="",depth=1):
        if clean:
            self.string = string.replace("(","").replace(")","").replace(":","").replace("Sub-Class Table ","")
        else:
            self.string = string

        if parent is None:
            self.parent = None
        else:
            self.parent = parent.copy()

        self.depth = depth
        self.name = name
        self.members = self.arraycopy(members)

        if clean:
            self.clean()
    
    def arraycopy(self,arr):
        n = []
        for m in arr:
            n.append(m.copy())
        return n

    def copy(self):
        return subtable(self.string,self.parent,self.members,False,self.name,self.depth)

    def clean(self):
        split = self.string.split(" ")
        self.depth = split.count("") + 1
        self.name = split[-1]
    
    def getmember(self,name):
        for np in self.members:
            if np.name == name:
                return np
        return None

    def printstr(self,prefix=""):
        return (prefix*(self.depth-1)) + self.name

    def printstrfull(self,prefix=""):
        return (prefix*(self.depth-1)) + self.name + " " + str(len(self.members))

    def printstrparented(self,prefix=""):
        if self.parent is None:
            return (prefix*(self.depth-1)) + self.name
        else:
            return self.parent.printstrparented(prefix) + "." + self.name

class netprop:
    def __init__(self,string,parent,clean=True,name="",depth=1,offset=0,typ="",bits=0):
        if clean:
            self.string = string.replace("(","").replace(")","").replace("-Member","").replace(":","").replace("-","")
        else:
            self.string = string

        if parent is None:
            self.parent = None
        else:
            self.parent = parent

        self.depth = depth
        self.name = name
        self.offset = offset
        self.type = typ
        self.bits = bits
        if clean:
            self.clean()
    
    def clean(self):
        split = self.string.split(" ")
        namefound = False
        i = 0
        while i < len(split):
            ch = split[i]
            if ch == "":
                self.depth += 1
                i += 1
                continue

            if not namefound:
                self.name = ch
                namefound = True
                i += 1
            
            if ch == "offset":
                self.offset = int(split[i+1])
                i += 2
            
            if ch == "type":
                self.type = split[i+1]
                i += 2
            
            if ch == "bits":
                self.bits = int(split[i+1])
                i += 1
                break
    
    def copy(self):
        return netprop(self.string,self.parent,False,self.name,self.depth,self.offset,self.type,self.bits)

    def printstr(self,prefix=""):
        return (prefix*(self.depth-1)) + self.name
    
    def printstrfull(self,prefix=""):
        return (prefix*(self.depth-1)) + self.name + " " + self.type + " " + str(self.bits)

    def printstrparented(self,prefix=""):
        if self.parent is None:
            return (prefix*(self.depth-1)) + self.name
        else:
            return self.parent.printstrparented(prefix) + "." + self.name

def getPageContent(_url):
    con = request.urlopen(request.Request(_url, headers={'User-Agent' : "Magic Browser"} ) )
    return con.read()

urls = [
    "https://wiki.alliedmods.net/Left_4_Dead_2_Netprops",
    "https://wiki.alliedmods.net/Left_4_Dead_2_Netprops_2",
    "https://wiki.alliedmods.net/Left_4_Dead_2_Netprops_3"
]

contentelementtag = "div"
contentelementclass = "mw-parser-output"

netproptableheaderclass = "mw-headline"
netproptableheadertag = "span"
netproptabletag = "pre"

subtablename = "Sub-Class Table"
membername = "-Member:"
netpropdict = dict()

for url in urls:
    soup = BeautifulSoup(getPageContent(url),features="html.parser").find(contentelementtag, {"class":contentelementclass})
    
    netproptablename = soup.find(netproptableheadertag,{"class":netproptableheaderclass})
    netproptable = soup.find(netproptabletag)

    while netproptable is not None and netproptablename is not None:
        key = netproptablename.string.replace(":","")
        vals = netproptable.string.split("\n")

        currentparent = None
        tables = {}
        currentdepth = 1
        for row in vals:
            if row == "":
                continue
            
            if subtablename in row:
                currentparent = subtable(row,currentparent)
                currentdepth = currentparent.depth
                if currentdepth in tables.keys():
                    tables[currentdepth].append(currentparent)
                else:
                    tables[currentdepth] = [currentparent]

                #print(("-"*currentparent.depth)+currentparent.printstrparented())

            elif membername in row:
                netp = netprop(row,currentparent)

                if netp.depth != currentdepth:
                    currentdepth = netp.depth
                    currentparent = tables[currentdepth-1][-1]
                    netp.parent = currentparent

                currentparent.members.append(netp)
                
                #print(("-"*netp.depth)+netp.printstrparented())

        netpropdict[key] = classtable(key,tables)

        netproptable = netproptable.find_next_sibling(netproptabletag)
        netproptablename = netproptablename.find_next(netproptableheadertag)

print(netpropdict.__len__())

"""
print("-------------------------")

totalmembercount = 0
for cl,tbl in netpropdict.items():
    mbc = tbl.membercount
    print(cl+" : "+str(mbc))
    totalmembercount += mbc

print("-------------------------")
"""

testclass = "Witch"
testprop = "lengthprop6"
subtableprefix = ">"
memberprefix = " "

print(netpropdict[testclass].depth)
print(netpropdict[testclass].tablecount)
print(netpropdict[testclass].membercount)
print(netpropdict[testclass].getmember(testprop).printstrparented())

#netpropdict[testclass].printbydepthfull(subtableprefix,memberprefix)

allprops = classcollection(netpropdict)
#print(allprops.sqtable())

filedir = "./2229460523/scripts/vscripts/resource_tables/netproptables.nut"

with open(filedir, "w") as netpropfile:
    print("::NetPropTables <- \n" + allprops.sqtable(),file=netpropfile)