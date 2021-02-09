from bs4 import BeautifulSoup
from urllib import request
from helperclasses.netprops import classcollection,classtable,subtable,netprop 

# TO-DO: Issue with parenting with same depth tables back-to-back

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

writetofile = input("Write to file (Y/N)? ")
if str(writetofile).lower() == "y":
    with open(filedir, "w") as netpropfile:
        print("::NetPropTables <- \n" + allprops.sqtable(),file=netpropfile)

input("\nPress any key to quit...")