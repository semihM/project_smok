import math

SOUND_DEFAULT = "buttons/button14" 

DIRECTION_BACK = " << Back" 
DIRECTION_BACK_INDEX = 8
DIRECTION_NEXT = " >> Next" 
DIRECTION_EXIT = " Exit" 

class Templates:
    def cmddefault(menuname):
        return "play "+SOUND_DEFAULT+";"+"scripted_user_func ;show_menu "+menuname

    def exitdefault():
        return "play "+SOUND_DEFAULT+";" 

    def labeldefault(index):
        return " Label_"+str(index)

    def cmdpropdynamicdefault(menuname):
        return "play "+SOUND_DEFAULT+";"+"scripted_user_func prop,dynamic,;show_menu "+menuname

    def labelpropdynamicdefault(index):
        return " dynamic_prop_"+str(index)

class element:
    def __init__(self,index=1,command="",label="",_next=None,**kwargs):
        self.index = index
        self.command = command
        self.label = label
        self.extras = kwargs
        self.next = _next

    def copy(self):
        return element(self.index,self.command,self.label)

    def connect(self,other):
        self.next = other
        split = self.command.split(";")
        self.command = ";".join(split[:-1]) + "show_menu " + other.name

    def printstr(self,prefix=""):
        s = prefix + '"'+str(self.index)+'"\n'+prefix+'{\n\t'
        s += prefix + '"command"\t"'+self.command+'"\n\t'
        s += prefix + '"label"\t\t"'+str(self.label)+'"\n'+prefix+'}'
        return s

class direlement(element):
    def __init__(self,index=DIRECTION_BACK_INDEX,other=None,direction=DIRECTION_BACK,extracommand="",sound=SOUND_DEFAULT,**kwargs):
        if other is None:
            super().__init__(index,"play "+sound+";"+extracommand+";show_menu ",direction,None,**kwargs)
        else:
            super().__init__(index,"play "+sound+";"+extracommand+";show_menu "+other.name,direction,other,**kwargs)

class subdirelement(element):
    def __init__(self,index=1,other=None,label="",extracommand="",sound=SOUND_DEFAULT,**kwargs):
        if other is None:
            super().__init__(index,"play "+sound+";"+extracommand+";"+"show_menu ",label,None,**kwargs)
        else:
            super().__init__(index,"play "+sound+";"+extracommand+";"+"show_menu "+other.name,label,other,**kwargs)

class menu:
    def __init__(self,prefix="",name="",suffix="",title="",elements=[],_prev=None,_next=None):
        self.prefix = str(prefix)
        self.suffix = str(suffix)
        self.name = self.prefix + str(name) + self.suffix
        self.title = str(title)
        self.elements = []
        self.arraycopy(elements,self.elements)
        self.prev = _prev
        self.next = _next
    
    def arraycopy(self,arr,newarr):
        for e in arr:
            newarr.append(e.copy())
        return newarr

    def printallprevstr(self):
        s = "" 
        current = self.prev
        while current is not None:
            s += current.printstr() + "\n" 
            current = current.prev
        return s

    def printstr(self):
        length = len(self.elements)
        s = '"'+self.name+'"\n{\n\t'
        s += '"Title"\t\t"'+self.title+'"\n'
        for i in range(length):
            element = self.elements[i]
            s += element.printstr("\t")
            if i != length - 1:
                s += "\n" 
        s += "\n}" 
        return s

    def printallnextstr(self):
        s = "" 
        current = self.next
        while current is not None:
            s += current.printstr() + "\n" 
            current = current.next
        return s

    def printallstr(self):
        return self.printallprevstr() + "\n" + self.printstr() + "\n" + self.printallnextstr()

def connectMenusForward(submenus,index):
    for i in range(len(submenus)-1):
        submenus[i].elements[index].connect(submenus[i+1])
        submenus[i].next = submenus[i].elements[index].next

def createDirElement(_prev,_next,index=DIRECTION_BACK_INDEX):
    return [direlement(index,_prev),direlement(index+1,_next,DIRECTION_NEXT)]

def createExitElement(index=0):
    return element(index,Templates.exitdefault(),DIRECTION_EXIT)

def createDeleteElement(name,index=7):
    return element(index,Templates.deletefault(name))

def addFirstPageExtras(lis,_prev):
    lis.extend(createDirElement(_prev,None))
    lis.append(createExitElement())

def createEmptyMenu(name,title,pageCount=1,elementEachPage=6,_prev=None,functemplate=None,labeltemplate=None,arguments=[]):
    submenus = []
    elements = []
    elementEachPage = min(max(1,elementEachPage),7)
    pageCount = max(1,pageCount)

    if functemplate is None:
        functemplate = Templates.cmddefault

    if labeltemplate is None:
        labeltemplate = Templates.labeldefault

    if "$argument" in functemplate(""):
        i = 1
        argsleft = len(arguments)

        for index in range(1,min(elementEachPage,len(arguments))+1):
            c_arg = arguments[(index-1)]
            elements.append(element(index,functemplate(name+str(i)).replace("$argument",c_arg),labeltemplate(index).replace("$argument",c_arg)))

        argsleft -= elementEachPage

        addFirstPageExtras(elements,_prev)
        submenu = menu(name=name,suffix=i,title=title+" "+str(i),elements=elements)
        submenus.append(submenu)

        i += 1
        while argsleft > 0:
            elements = []  
            for index in range(1,min(elementEachPage,argsleft)+1):
                c_arg = arguments[((i-1)*elementEachPage)+(index-1)]
                elements.append(element(index,functemplate(name+str(i)).replace("$argument",c_arg),labeltemplate(index).replace("$argument",c_arg)))
            
            argsleft -= elementEachPage
            if i == pageCount:
                elements.append(direlement(DIRECTION_BACK_INDEX,submenus[i-2]))
            else:
                elements.extend(createDirElement(submenus[i-2],None))
            elements.append(createExitElement())
            submenu = menu(name=name,suffix=i,title=title+" "+str(i),elements=elements)
            submenus.append(submenu)
            i += 1
    else:
        i = 1
        for index in range(1,elementEachPage+1):
            elements.append(element(index,functemplate(name+str(i)),labeltemplate(index)))
        addFirstPageExtras(elements,_prev)
        submenu = menu(name=name,suffix=i,title=title+" "+str(i),elements=elements)
        submenus.append(submenu)
        i += 1
        while i <= pageCount:
            elements = []  
            for index in range(1,elementEachPage+1):
                elements.append(element(index,functemplate(name+str(i)),labeltemplate(index)))
            if i == pageCount:
                elements.append(direlement(DIRECTION_BACK_INDEX,submenus[i-2]))
            else:
                elements.extend(createDirElement(submenus[i-2],None))
            elements.append(createExitElement())
            submenu = menu(name=name,suffix=i,title=title+" "+str(i),elements=elements)
            submenus.append(submenu)
            i += 1

    connectMenusForward(submenus,elementEachPage+1)
    return submenus

decalsmain = "decals_main_menu1" 
basename = "decals_" 
basetitle = " decals" 
label = " $argument" 
name = "wallpapers" 
title = name
 
arguments = []

propPerPage = 7
pageCount = math.ceil(len(arguments) / float(propPerPage))

def decallabeler(index):
    return label

def decalcmd(menuname):
    return "play "+SOUND_DEFAULT+";"+"scripted_user_func decal,$argument;show_menu "+menuname

Templates.decallabeler = decallabeler
Templates.decalcmd = decalcmd
basename += name
basetitle = title + basetitle

propdynamicmenuempty = createEmptyMenu(basename,basetitle,pageCount,propPerPage,None,Templates.decalcmd,Templates.decallabeler,arguments)

filedir = "./menus/" 

with open(filedir+basename, "w") as f:
    print((propdynamicmenuempty[0].printallstr()).encode("ascii","ignore").decode("ascii"),file=f)