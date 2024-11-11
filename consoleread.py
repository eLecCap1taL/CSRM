import os
import re
import time
import threading
import json

logfile_path = '../../console.log'
soundinfo_callback_file = './Addon/consoleReader/soundinfo_callback.cfg'
last_size = 0
last_coords = (0,0,0)

def updateCoords(res):
    global last_coords
    global server
    coords = tuple(map(float, res.groups()))
    if coords != last_coords:
        last_coords = coords
        json_coords = json.dumps(last_coords)
        server.send_message_to_all(json_coords)
        # print('Sending Coordinates to Clients:', last_coords)
        
banweapon = [
    "glock",
    "elite",
    "knife",
    "p250",
    "tec9",
    "de",
    "hkp2000",
    "fiveseven",
    "bizon",
    "mp9",
    "mac10",
    "mp5",
    "smokegrenade",
    "decoy",
    "molotov",
    "he",
    "flashbang",
    "inc_grenade"
]
def soundinfo_weapon(res):
    wp=res.group(1)
    # print(wp)
    # print(f"pass {wp}") 
    with open(soundinfo_callback_file,'w', encoding='utf-8', errors='ignore') as f:
        if wp in banweapon:
            f.write(f"csrmConsoleReader_soundinfo_none")
            print(f"csrmConsoleReader_soundinfo_none")
        else:
            f.write(f"csrmConsoleReader_soundinfo_{wp}")
            print(f"csrmConsoleReader_soundinfo_{wp}")

patternpair = [
    (re.compile(r'([^\\]+)_draw\.vsnd'),soundinfo_weapon)
]

def process_log_file():
    global last_size
    global patternpair
    if os.path.exists(logfile_path):
        with open(logfile_path, 'r', encoding='utf-8', errors='ignore') as f:

            if os.path.getsize(logfile_path)<last_size:
                last_size=0

            f.seek(last_size)
            lines = f.readlines()
            last_size = f.tell()

            for line in lines:
                print(line)   
                for pr,func in patternpair:
                    matchRes = pr.search(line)
                    if matchRes is not None:
                        func(matchRes)
    return

def mainloop():
    while True:
        process_log_file()
        time.sleep(0.005)

if __name__ == "__main__":
    with open(soundinfo_callback_file,'w', encoding='utf-8', errors='ignore') as f:
        f.write(f"csrmConsoleReader_soundinfo_none")
        print(f"csrmConsoleReader_soundinfo_none")
    mainloop()
