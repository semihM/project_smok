import os
import re

BASEDIR = f"{os.getenv('USERDOWNLOADS')}/extr/materials/"

SCRIPT_NAME = re.compile("^(\w+)[\t{ ]*$")
SCRIPT_END = re.compile("^}")
SCRIPT_REGULAR = re.compile("(\$\w+|%\w+|\w+)[\t ]+(.*)")

MATERIALS = {}

def escapes(st):
    return st.strip().replace("\\","/").replace("\n","\\n").replace("\t","\\t").replace("\r","\\r").replace("\"","'")

def addToMaterialList(splt,cat=""):
    if splt[1] != "vmt":
        return
    mname = cat+splt[0]
    if mname not in MATERIALS.keys():
        MATERIALS[mname] = material(mname)

class node:
    def __init__(self,name):
        self.name = name
        self.parent = None
        self.values = dict()
        self.children = []
        self.completed = False
    
    def getdepth(self):
        p = self.parent
        d = 1
        while p is not None:
            p = p.parent
            d += 1
        return d

    def sqtbl(self,prefix="\t"):
        s = prefix+f"\"{self.name}\":\n"
        s += prefix+"{\n"
        if len(self.values) != 0:
            s += prefix + "\t" + (("\n"+prefix+"\t").join(["\""+k+"\": \""+escapes(v)+"\"" for k,v in self.values.items()])) + "\n" 
        if len(self.children) != 0:
            s += "\n".join([ch.sqtbl("\t"*(ch.getdepth()+len(prefix)-1)) for ch in self.children]) + "\n"
        s += prefix+"}"

        return s

class material:
    def __init__(self,path):
        self.path = path
        self.table = node("")

    def sqtbl(self,prefix="\t"):
        s = prefix + "{\n"
        s += prefix + "\t\"path\": \"" + self.path + "\"\n"
        s += prefix + "\t\"main\": \"" + self.table.name + "\"\n"
        s += self.table.sqtbl("\t\t") + "\n"
        s += prefix + "}\n"
        return s
    
    def readvmt(self):
        with open(BASEDIR+self.path+".vmt", "r",errors="replace") as _file:
            file = _file.read()
            current = None

            for line in file.split("\n"):
                if line.strip() == "":
                    continue

                if current is None:
                    name_match = SCRIPT_NAME.search(line)
                    if name_match is not None:
                        current = node(name_match.groups()[0])
                    else:
                        raise Exception(f"EXPECTED NAME( {self.path} ):"+line)
                else:
                    if SCRIPT_END.search(line) is not None:
                        current.completed = True
                        if current.parent is not None:
                            current = current.parent
                        else:
                            break
                    else:
                        n_start = SCRIPT_NAME.search(line)
                        if n_start is not None:
                            new_node = node(n_start.groups()[0])
                            new_node.parent = current
                            current.children.append(new_node)
                            current = new_node
                        else:
                            kvs = SCRIPT_REGULAR.search(line)
                            if kvs is not None:
                                kvs = kvs.groups()
                                key = kvs[0]
                                val = kvs[1]
                                if val[0] in ["\"","'"] and val[-1] in ["\"","'"]:
                                    val = val[1:-1]
                                current.values[key] = val

            self.table = current

def createToMaterialDict(cat=""):
    if cat != "":
        cat = cat+"/"
    for category in os.listdir(BASEDIR+cat):
        #print(cat+category)
        if "." in category:
            addToMaterialList(category.split("."),cat)
        else:
            createToMaterialDict(cat+category)

createToMaterialDict(cat="")

print(MATERIALS.__len__())


res = "{"

for m,mcls in MATERIALS.items():
    mcls.readvmt()
    res += "\n\t\""+m+"\":\n"+mcls.sqtbl()
    
# Custom models
custom = material("models/can/cup")
custom_node = node("VertexLitGeneric")
custom_node.values["$basetexture"] = "models\can\cup"
custom_node.values["$surfaceprop"] = "cardboard"
custom.table = custom_node

MATERIALS["models/can/cup"] = custom
res += "\n\t\"models/can/cup\":\n"+custom.sqtbl() 

#########

res += "}"

filedir = "./2229460523/scripts/vscripts/resource_tables/materialdetails.nut"

writetofile = input("Write to file (Y/N)? ")
if str(writetofile).lower() == "y":
    with open(filedir, "w") as entfile:
        print(("::MaterialDetails <- \n" + res).encode("ascii","ignore").decode("ascii"),file=entfile)

input("\nPress any key to quit...")