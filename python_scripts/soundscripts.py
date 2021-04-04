from os import O_APPEND
import re

def escapes(st):
    return st.strip().replace("\\","/").replace("\n","\\n").replace("\t","\\t").replace("\r","\\r").replace("\"","'")

class kvpair:
    def __init__(self,key="",val=""):
        self.key = key
        self.val = val

class kvpairs:
    def __init__(self,pairs=[]):
        self.pairs = []

class ss:
    def __init__(self,name="",ch="",vol="",p="",lvl="",w=""):
        self.name = name
        self.channel = ch
        self.volume = vol
        self.pitch = p
        self.soundlevel = lvl
        self.wave = w
        self.extras = dict()
        self.caption = ""

    def setval(self,key,val):
        if key == "name":
            self.name = val
        elif key == "channel":
            self.channel = val
        elif key == "volume":
            self.volume = val
        elif key == "pitch":
            self.pitch = val
        elif key == "soundlevel":
            self.soundlevel = val
        elif key == "wave":
            self.wave = val
        else:
            print("UNKNOWN KEY: "+key)
            raise Exception()

    def sqtable(self,prefix="\t"):
        s = "\""+self.name+"\":\n"+prefix+"{"
        
        s += "\n\t"+prefix+"\"script\": " + "\"" + self.name + "\""

        if self.caption != "":
            s += "\n\t"+prefix+"\"caption\": " + "\"" + escapes(self.caption) + "\"" 

        if self.channel != "":
            s += "\n\t"+prefix+"\"channel\": " + "\"" + self.channel + "\"" 
            
        if self.volume != "":
            s += "\n\t"+prefix+"\"volume\": " + "\"" + self.volume + "\""
            
        if self.pitch != "":
            s += "\n\t"+prefix+"\"pitch\": " + "\"" + self.pitch + "\""
            
        if self.soundlevel != "":
            s += "\n\t"+prefix+"\"soundlevel\": " + "\"" + self.soundlevel + "\""
            
        if self.wave != "":
            s += "\n\t"+prefix+"\"wave\": " + "\"" + escapes(self.wave) + "\""
            
        if len(self.extras) != 0:
            s += "\n\t"+prefix + ("\n\t"+prefix).join(["\""+tname+"\":\n\t"+prefix+"[\n\t\t"+prefix+(",\n\t\t"+prefix).join(["[\""+p.key+"\", \""+escapes(p.val)+"\"]" for p in tvals.pairs])+"\n\t"+prefix+"]" for tname,tvals in self.extras.items()])
        s += "\n"+prefix+"}"
        return s

    def __str__(self):
        return self.name \
            + "\n\t channel: " + self.channel \
            + "\n\t volume: " + self.volume \
            + "\n\t pitch: " + self.pitch \
            + "\n\t soundlevel: " + self.soundlevel \
            + "\n\t wave: " + self.wave \
            + "\n\t " + "\n\t ".join([tname+": "+"\n\t\t ".join([p.key+":"+p.val for p in tvals.pairs]) for tname,tvals in self.extras.items()])

def readfile(file,ss_dict):
    current = ss()
    current_extra = ""
    last_match = ""

    for line in file.split("\n"):
        line = line.rstrip()
        if line.lstrip() == "":
            continue

        if SCRIPT_END.match(line):
            if current.name in ss_dict.keys():
                print("DUPLICATE("+str(len(current.name))+"): "+current.name)
            ss_dict[current.name] = current
            #print(current)
            current = ss()
            last_match = ""
            continue

        if last_match == "":
            match = SCRIPT_CAPTION.search(line)
            if match is not None:
                current.caption = match.groups()[0]
                last_match = "caption"
            else:
                match = SCRIPT_NAME.search(line)
                if match is not None and match.groups()[0].strip() != "":
                    current.name = match.groups()[0]
                    last_match = "name"
        
        elif last_match == "caption":
            match = SCRIPT_CAPTION.search(line)
            if match is not None:
                current.caption = ""
                last_match = "caption"
            else:
                match = SCRIPT_NAME.search(line)
                if match is not None and match.groups()[0].strip() != "":
                    current.name = match.groups()[0]
                    last_match = "name"

        elif last_match == "name":
            match = SCRIPT_START.search(line)
            if match is not None:
                last_match = "start"

        elif last_match == "start" or last_match == "regular" or last_match == "s_table_end":
            match = SCRIPT_REGULAR.search(line)
            if match is not None:
                last_match = "regular"
                match = match.groups()
                current.setval(match[0],match[1])
            else:
                match = SCRIPT_TABLE_NAME.search(line)
                if match is not None:
                    last_match = "s_table_start"
                    current_extra = match.groups()[0]
                    current.extras[current_extra] = kvpairs()
            
        elif last_match == "s_table_start":
            match = SCRIPT_TABLE_START.search(line)
            if match is not None:
                last_match = "s_table"

        elif last_match == "s_table" or last_match == "s_table_regular":
            match = SCRIPT_REGULAR.search(line)
            if match is not None:
                last_match = "s_table_regular"
                match = match.groups()
                current.extras[current_extra].pairs.append(kvpair(match[0],match[1]))
            else:
                match = SCRIPT_TABLE_END.search(line)
                if match is not None:
                    last_match = "s_table_end"
                    current_extra = ""

FILES = dict(
    {
        "dlc0":["000","007","013"],
        "dlc1":["000"],
        "dlc2":["000","001"],
        "dlc3":["003"]
    })

DIRBASE = "./built_in/soundscripts/"
CUSTOMDIRBASE = "./2229460523/maps/c1m1_hotel_level_sounds.txt"
SCRIPT_CAPTION = re.compile("^//\s*\"?(.*)\"?")
SCRIPT_NAME = re.compile("^\"(\w+(?:\.\w+)*)\"")
SCRIPT_START = re.compile("^{")
SCRIPT_END = re.compile("^}")
SCRIPT_REGULAR = re.compile("^[\t ]+\"(\w+)\"[\t ]+\"(.*)\"")
#SCRIPT_COMMENT = re.compile("^[\t ]+//(.*)\"")
SCRIPT_TABLE_NAME = re.compile("^[\t ]+\"?(\w+)\"?$")
SCRIPT_TABLE_START = re.compile("^[\t ]+{")
SCRIPT_TABLE_END = re.compile("^[\t ]+}")
ss_dict = dict()

for sdir,fnames in FILES.items():
    for fname in fnames:
        with open(DIRBASE+sdir+"/pak01_"+fname+".txt", "r", errors="ignore") as _file:
            readfile(_file.read(),ss_dict)

# Custom scripts
with open(CUSTOMDIRBASE, "r", errors="ignore") as _file:
    readfile(_file.read(),ss_dict)
            
            
"""
for k,v in ss_dict.items():
    print("\n"+str(v))
"""

res = "{\n\t"+"\n\n\t".join([scr.sqtable() for scr in ss_dict.values()])+"\n}"
filedir = "./2229460523/scripts/vscripts/resource_tables/soundscripts.nut"

writetofile = input("Write to file (Y/N)? ")
if str(writetofile).lower() == "y":
    with open(filedir, "w") as entfile:
        print(("::SoundScripts <- \n" + res).encode("ascii","ignore").decode("ascii"),file=entfile)

input("\nPress any key to quit...")