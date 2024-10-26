from websocket_server import WebsocketServer
import os
import re
import time
import threading
import json

logfile_path = '../../console.log'
last_size = 0
server = None
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
    "flashbang"
]
def soundinfo_weapon(res):
    wp=res.group(1)
    print(wp)
    if wp in banweapon:
        return
    print(f"pass {wp}") 

patternpair = [
    (re.compile(r'(?i).*C4.*Bounds Center: \(([-+]?\d*\.\d+|\d+),\s*([-+]?\d*\.\d+|\d+),\s*([-+]?\d*\.\d+|\d+)\)'),updateCoords),
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
        time.sleep(0.02)

def run_server():
    global server
    server = WebsocketServer(host='0.0.0.0', port=8000)

    def new_client(client, server):
        print("------------------")
        print(client)
        print("New client connected")
        print("------------------")

    def left_client(client, server):
        print("------------------")
        print(client)
        print("A Client Disconnected")
        print("------------------")

    server.set_fn_new_client(new_client)
    server.set_fn_client_left(left_client)

    server.run_forever()

if __name__ == "__main__":
    server_thread = threading.Thread(target=run_server)
    server_thread.start()
    time.sleep(2)
    mainloop()
