import os
import re

BASEDIR = f"{os.getenv('USERDOWNLOADS')}/extr/models/"

MODELS = {}

def escapes(st):
    return st.strip().replace("\\","/").replace("\n","\\n").replace("\t","\\t").replace("\r","\\r").replace("\"","'")

def addToModelList(splt,cat=""):
    mname = cat+splt[0] # ignores .dx90 bits
    mext = splt[-1]

    if mname not in MODELS.keys():
        MODELS[mname] = model(mname)

    MODELS[mname].extensions.append(mext)


class model:
    def __init__(self,path):
        self.model = path
        self.extensions = []
        self.prop_data = None
        self.mdl_data = None

    def hasPhys(self):
        return "true" if "phy" in self.extensions else "false"

    def sqtbl(self,prefix="\t"):
        s = prefix + "{\n"
        s += prefix + "\t\"path\": \"" + self.model + "\"\n"
        if self.mdl_data is not None:
            s += prefix + "\t" + (("\n"+prefix+"\t").join(["\""+k+"\": \""+escapes(v)+"\"" for k,v in self.mdl_data.items()])) + "\n"
        if self.prop_data is not None:
            s += prefix + "\t" + (("\n"+prefix+"\t").join(["\""+k+"\": "+("\""+escapes(v)+"\"" if type(v) == type("") else "[]" if len(v)==0 else "\n\t"+prefix+"[\n\t\t"+prefix+((",\n\t\t"+prefix).join(["\""+_v+"\"" for _v in v]))+"\n\t"+prefix+"]") for k,v in self.prop_data.items()])) + "\n"
        s += prefix + "}\n"
        return s
    
    def readmdl(self):
        s = ""
        anims = ""
        tbl = {}
        with open(BASEDIR+self.model+".mdl", "r",errors="replace") as _file:
            f = _file.read()
            pdata = False
            for line in f.split("\n"):
                if pdata:
                    s += line.rstrip() + "\n"
                    if line == "}":
                        pdata = False
                else:
                    # TO-DO: Find a way to reliably decide ending point
                    if line.find("default"+"\x00"+"@") != -1:
                        i = line.index("default"+"\x00"+"@")
                        line = line[i:].replace("\x00"," ")
                        anims += line.rstrip() + "\n"

                    elif line.find("L4D"+"\x00"+"@") != -1:
                        i = line.index("L4D"+"\x00"+"@")
                        line = line[i:].replace("\x00"," ")
                        anims += line.rstrip() + "\n"
                        if anims.find("f01") != -1: 
                            anims = anims[:anims.index("f01")].strip()
                    
                    elif line.find("cstrike"+"\x00"+"@") != -1:
                        i = line.index("cstrike"+"\x00"+"@")
                        line = line[i:].replace("\x00"," ")
                        anims += line.rstrip() + "\n"
                        if anims.find("rhand") != -1: 
                            anims = anims[:anims.index("rhand")].strip()
                        elif anims.find("f01") != -1: 
                            anims = anims[:anims.index("f01")].strip()

                    elif line.find("L4D_Witch"+"\x00"+"@") != -1:
                        i = line.index("L4D_Witch"+"\x00"+"@")
                        line = line[i:].replace("\x00"," ")
                        anims += line.rstrip() + "\n"
                        if anims.find("body_pitch") != -1: 
                            anims = anims[:anims.index("body_pitch")].strip()
                        elif anims.find("f01") != -1: 
                            anims = anims[:anims.index("f01")].strip()
                        elif anims.find("rhand") != -1: 
                            anims = anims[:anims.index("rhand")].strip()

                    elif line.find("rhand"+"\x00"+"@") != -1:
                        i = line.index("rhand"+"\x00"+"@")
                        line = line[i:].replace("\x00"," ")
                        anims += line.rstrip() + "\n"
                        if anims.find("move_yaw") != -1: 
                            anims = anims[:anims.index("move_yaw")].strip()
                        elif anims.find("body_pitch") != -1: 
                            anims = anims[:anims.index("body_pitch")].strip()
                        elif anims.find("f01") != -1: 
                            anims = anims[:anims.index("f01")].strip()
                        elif anims.find("rhand") != -1: 
                            anims = anims[:anims.index("rhand")].strip()

                    elif line.find("spitter"+"\x00"+"@") != -1:
                        i = line.index("spitter"+"\x00"+"@")
                        line = line[i:].replace("\x00"," ")
                        anims += line.rstrip() + "\n"
                        if anims.find("move_yaw") != -1: 
                            anims = anims[:anims.index("move_yaw")].strip()
                        elif anims.find("body_pitch") != -1: 
                            anims = anims[:anims.index("body_pitch")].strip()
                        elif anims.find("f01") != -1: 
                            anims = anims[:anims.index("f01")].strip()
                        elif anims.find("rhand") != -1: 
                            anims = anims[:anims.index("rhand")].strip()

                    elif "prop_data" in line:
                        pdata = True
                        s += line.rstrip() + "\n"
        
        tbl["data"] = s

        if anims != "":
            seq_list = []
            # TO-DO: Dont ignore body parts
            splt = anims.split(" ")
            typ = splt[0]
            splt = splt[1:]
            if typ == "default":
                for v in anims.split(" ")[1:]:
                    if v[0] != "@":
                        break
                    else:
                        seq_list.append(v[1:])
            elif typ in ["L4D","cstrike","L4D_Witch","rhand","spitter"]: 
                for v in anims.split(" ")[1:]:
                    if v.upper() == v: # Skip activities
                        continue

                    v = v.lower()

                    if v[:2] == "a_":
                        continue

                    if v[0] == "@":
                        v = v[1:]

                    if v not in seq_list:
                        seq_list.append(escapes(v))

            tbl["sequences"] = seq_list

        return tbl

    def readphy(self):
        if self.hasPhys() == "false":
            return None

        tbl = {}

        with open(BASEDIR+self.model+".phy", "r",errors="replace") as _file:
            f = _file.read()
            for line in f.split("\n"):
                catch = re.search("\"([^\"]*)\"[\t ]*\"(\d*\.?\d*)\"",line)
                if catch is not None:
                    key = catch.groups()[0]
                    val = catch.groups()[1]
                    tbl[key] = val

        return tbl

for category in os.listdir(BASEDIR):
    if "." in category:
        addToModelList(category.split("."))
    else:
        spath = category+"/"
        for subcategory in os.listdir(BASEDIR+spath):
            if "." in subcategory:
                addToModelList(subcategory.split("."),spath)
            else:
                mpath = spath+subcategory+"/"
                for mdlname in os.listdir(BASEDIR+mpath):
                    addToModelList(mdlname.split("."),mpath)

print(MODELS.__len__())


res = "{"

for m,mcls in MODELS.items():
    mcls.mdl_data = mcls.readphy()
    mcls.prop_data = mcls.readmdl()
    res += "\n\t\""+m+"\":\n"+mcls.sqtbl() 
    
# Custom models
custom = model("can")
custom.mdl_data = {"mass":"1.000000","totalmass":"1.000000"}
MODELS["can"] = custom
res += "\n\t\"can\":\n"+custom.sqtbl() 

#########

res += "}"

filedir = "./2229460523/scripts/vscripts/resource_tables/modeldetails.nut"

writetofile = input("Write to file (Y/N)? ")
if str(writetofile).lower() == "y":
    with open(filedir, "w") as entfile:
        print(("::ModelDetails <- \n" + res).encode("ascii","ignore").decode("ascii"),file=entfile)

input("\nPress any key to quit...")