from pathlib import Path

MAPSCRPATH = "./2229460523/maps/"
NEWSCRIPT = """
\"loot_get\"
{
	\"channel\"		\"CHAN_STATIC\"
	\"volume\"		\"0.9\"
	\"pitch\"			\"PITCH_NORM\"
	\"soundlevel\"	    \"SNDLVL_130dB\"
	\"wave\"	\"lootget/lootget.wav\"
}
"""
pathlist = Path(MAPSCRPATH).glob('*.txt')
for path in pathlist:
    path_in_str = str(path)
    with open(path_in_str, "a") as f:
        f.write(NEWSCRIPT)