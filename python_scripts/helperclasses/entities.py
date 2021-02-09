NO_DESCRIPTION = "No description found."
NO_KEYNAME = "UNKNOWN_KEY_NAME"
NO_TYPE = "UNKNOWN_VAL_TYPE"
NO_EXTRA = "No extra short-information given"
NO_IMG_ALT = "UNKNOWN_GAME_REFERENCE"
PREDICTED_FLAG_VAL = "(FLAG VALUE MAY BE INCORRECT)"

class tempref:
    def __init__(self,ref):
        self.ref = ref

class errlis:
    def __init__(self):
        self.lis = []

class flag:
    def __init__(self,val,desc,cat=""):
        self.val = val
        self.description = desc
        self.category = cat.replace(":","").replace("(","").replace(")","")
        self.notetypes = list()
        self.notevals = list()
        self.clean()
        
    def clean(self):
        self.val = int(self.val.replace("[","").replace("]","").replace(" ",""))

    def getnotes(self):
        notestr = ""
        if(len(self.notetypes) == len(self.notevals)):
            length = len(self.notetypes)
            for i in range(length):
                notestr += escapes(self.notetypes[i])+" "+escapes(self.notevals[i])
                if i != length - 1:
                    notestr += "\\n"
        else:
            length = len(self.notevals)
            for i in range(length):
                notestr += escapes(self.notevals[i])
                if i != length - 1:
                    notestr += "\\n"
        return notestr

    def printstr(self):
        notestr = redoescapes(self.getnotes())
        catstr = ""
        if self.category != "":
            catstr = f" ({self.category})"
        return str(self.val) + catstr +": " + self.description + ". " + notestr

class keyvalpair:
    def __init__(self,lis,desc=""):
        self.keylis = lis
        self.key = lis[1].replace(" ","_").strip()
        self.shortinfo = lis[0].strip()
        self.typ = lis[2].replace(" ","_").replace("<","").replace(">","").strip()
        self.extra = lis[3].strip()
        self.description = desc
        self.descriptiondict = dict()
        self.notetypes = list()
        self.notevals = list()

    def printstr(self):

        extrastr = ""
        if self.extra.strip() != "":
            extrastr = "("+self.extra+")"

        return self.typ + " " + self.key + f"({self.shortinfo}){extrastr}:\n" + self.description + self.getnotes() + self.getchoices()

    def getnotes(self):
        notestr = ""
        if(len(self.notetypes) == len(self.notevals)):
            length = len(self.notetypes)
            for i in range(length):
                notestr += escapes(self.notetypes[i])+" "+escapes(self.notevals[i])
                if i != length - 1:
                    notestr += "\\n"
        else:
            length = len(self.notevals)
            for i in range(length):
                notestr += escapes(self.notevals[i])
                if i != length - 1:
                    notestr += "\\n"

        return notestr

    def getchoices(self):
        descdictstr = ""
        for k,v in self.descriptiondict.items():
            descdictstr += "\\n"+k+" -> "+v
        return descdictstr

    def sqgetchoicestable(self,prefix):
        if len(self.descriptiondict.keys()) == 0:
            return "{}"
        descdictstr = "\n" +prefix + "{\n"
        for k,v in self.descriptiondict.items():
            descdictstr += prefix + "\t" + "\""+k.replace(" ","").strip()+"\" : \""+escapes(v)+"\"\n"
        return descdictstr + "\n" + prefix + "}"

class entity:
    def __init__(self,name,link,title):
        self.name = name
        self.link = link
        self.linkvalid = True
        self.title = title
        self.description = ""
        self.flags = list()
        self.flagnotestypes = list()
        self.flagnotesvals = list()
        self.kvpairs = list()
        self.kvpairnotestypes = list()
        self.kvpairnotesvals = list()
        self.inputs = dict()
        self.outputs = dict()

    def printstr(self):
        l = ""
        if self.linkvalid is False:
            l = "(LINK_INVALID)"
        return self.title + f" ({self.name}){l}: " + self.link

    def getflagdict(self):
        d = dict()
        for i,flg in enumerate(self.flags):
            if flg.val in d.keys():
                d[flg.val].description += ". " + f"({flg.category})" + flg.description
                if len(flg.notetypes) != 0:
                    d[flg.val].notetypes.extend(flg.notetypes)
                    d[flg.val].notevals.extend(flg.notevals)
            else:
                d[flg.val] = flg
            
        return d
    
    def getflagnotes(self):
        notestr = ""
        if len(self.flagnotestypes) != 0:
            if len(self.flagnotestypes) != len(self.flagnotesvals):
                length = len(self.flagnotesvals)
                for i in range(length):
                    notestr += escapes(self.flagnotesvals[i])
                    if i != length -1:
                        notestr += "\\n"
            else:
                length = len(self.flagnotestypes)
                for i in range(length):
                    notestr += escapes(self.flagnotestypes[i]) + escapes(self.flagnotesvals[i])
                    if i != length - 1:
                        notestr += "\\n"
        return notestr

    def getkvpairnotes(self):
        notestr = ""
        if len(self.kvpairnotestypes) != 0:
            if len(self.kvpairnotestypes) != len(self.kvpairnotesvals):
                length = len(self.kvpairnotesvals)
                for i in range(length):
                    notestr += escapes(self.kvpairnotesvals[i])
                    if i != length -1:
                        notestr += "\\n"
            else:
                length = len(self.kvpairnotestypes)
                for i in range(length):
                    notestr += escapes(self.kvpairnotestypes[i]) + escapes(self.kvpairnotesvals[i])
                    if i != length - 1:
                        notestr += "\\n"
        return notestr

    def sqflagtable(self,prefix):
        if len(self.flags) == 0:
            return "{}"

        s = "\n" +prefix + "{\n"
        d = self.getflagdict()

        for val in sorted(d.keys(),key=lambda x:int(x)):
            flg = d[val]
            s += prefix + "\t\"" + str(val).strip() + "\":\n"
            s += prefix + "\t{\n"
            s += prefix + "\t\tcategory = \"" + escapes(flg.category) + "\"\n"
            s += prefix + "\t\tdescription = \"" + escapes(flg.description) + "\"\n" 
            s += prefix + "\t\tnotes = \"" + escapes(flg.getnotes()) + "\"\n" 
            s += prefix + "\t}\n"
        s += prefix + "}"
        return s

    def sqkvpairtable(self,prefix):
        if len(self.kvpairs) == 0:
            return "{}"

        s = "\n" +prefix + "{\n"
        unknowncount = 0
        for kv in self.kvpairs:
            if kv.key == NO_KEYNAME:
                unknowncount += 1
                s += prefix + "\t\"" + kv.key + "_" + str(unknowncount).strip() + "\":\n"
            else:
                s += prefix + "\t\"" + kv.key + "\":\n"
            s += prefix + "\t{\n"
            s += prefix + "\t\ttypename = \"" + escapes(kv.typ) + "\"\n"
            s += prefix + "\t\tshortinfo = \"" + escapes(kv.shortinfo) + "\"\n"
            s += prefix + "\t\textra = \"" + escapes(kv.extra) + "\"\n" 
            s += prefix + "\t\tnotes = \"" + escapes(kv.getnotes()) + "\"\n" 
            s += prefix + "\t\tdescription = \"" + escapes(kv.description) + "\"\n" 
            s += prefix + "\t\tchoices = "+ kv.sqgetchoicestable(prefix+"\t\t") + "\n" 
            s += prefix + "\t}\n"
        s += prefix + "}"
        return s

    def getsqtable(self,prefix):
        s = prefix + "{\n"
        s += prefix + "\tdescription = \""+escapes(self.description)+"\"\n"
        s += prefix + "\tflagnotes = \""+self.getflagnotes()+"\"\n"
        s += prefix + "\tflags = " + self.sqflagtable(prefix+"\t") + "\n" 
        s += prefix + "\tkeyvalnotes = \""+self.getkvpairnotes()+"\"\n" 
        s += prefix + "\tkeyvalues = " + self.sqkvpairtable(prefix+"\t") + "\n"
        s += prefix +"}"
        return s

class category:
    def __init__(self,prefix,ents=[]):
        self.prefix = prefix
        self.entities = ents
    
    def printstr(self):
        s = "["
        l = len(self.entities)
        if(l != 0):
            s += "\n"
        for i in range(l):
            ent = self.entities[i]
            s += "\t" + ent.printstr()
            if(i != l-1):
                s += ",\n"
            else:
                s += "\n"
        s += "]"
        return s

class categorycollection:
    def __init__(self,tabledict=dict()):
        self.tables = tabledict
    
    """
    category /
        entity /
            name
            description
            
            flagnotes 
            flags /
                +val /
                    desc
                    notes

            keyvalnotes
            keyvalues /
                +key /
                    typename
                    shortinfo
                    extra
                    notes
                    description
                    choices
            
            inputs
            outputs
    """
    def sqtable(self):
        s = "{\n\t"
        for catname,cat in self.tables.items():
            s += catname + " = \n\t{\n\t\t"
            for ent in cat.entities:
                s += ent.name.strip() + " = \n"
                s += ent.getsqtable("\t\t") + "\n\t\t"
                #s += "keyvals = \n"
            s += "\n\t}\n\t"
        s += "\n}"
        return s

def escapes(st):
    return st.strip().replace("\\","/").replace("\n","\\n").replace("\t","\\t").replace("\r","\\r").replace("\"","'")

def redoescapes(st):
    return st.strip().replace("\\n","\n").replace("\\t","\t").replace("\\r","\r").replace("\\\"","\"")