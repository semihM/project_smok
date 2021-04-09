import re

FILES = dict(
    {
        "dlc0":["dir"],
        "dlc1":["dir"],
        "dlc2":["dir"],
        "dlc3":["dir"],
        "update":["dir"]
    })

DIRBASE = "./built_in/decals/"
BASETXT = re.compile("^[\t ]*\$base[Tt]exture[\t ]+\"(.*)\"")

lis = []

# 000
with open(DIRBASE+"dlc0/pak01_000.txt", "r", errors="ignore") as _file:
    lis = _file.read().split("\n")

# dir
for sdir,fnames in FILES.items():
    for fname in fnames:
        with open(DIRBASE+sdir+"/pak01_"+fname+".txt", "r", errors="ignore") as _file:
            f = _file.read()
            for line in f.split("\n"):
                line = line.rstrip().replace("\\","/")
                catches = BASETXT.search(line)
                if catches is None:
                    continue
                else:
                    catches = catches.groups()
                    
                for d in catches:
                    if d in lis:
                        print("DUPLICATE: "+d)
                        continue
                    else:
                        lis.append(d)

res = "{\n\tall =\n\t[\n\t\ty"+",\n\t\t".join(["\""+dc+"\"" for dc in lis])+"\n\t]\n}"
filedir = "./2229460523/scripts/vscripts/resource_tables/decalpaths.nut"

writetofile = input("Write to file (Y/N)? ")
if str(writetofile).lower() == "y":
    with open(filedir, "w") as entfile:
        print(("::DecalPaths <- \n" + res).encode("ascii","ignore").decode("ascii"),file=entfile)

input("\nPress any key to quit...")