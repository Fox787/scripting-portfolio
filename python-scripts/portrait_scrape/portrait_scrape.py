# -*- coding: utf-8 -*-

import urllib.request
import time
import socket

deleted_message = "Shiver me timbers: Some horrible daemons have prevented us from processing yer request.  Please check to make sure that the message you typed is not too long, and try again."

last_time = time.time()
delay = 1.5
fail_allowance = 19 
start_id = 2664684  # ID that your latest portrait is
final_id = 2661626  # ID that you know is older than the portrait you wish to find
amount = 2000 # Maximum IDs to scrape, if more than final_id allows it is ignored
amount_id = start_id - amount - 1
if amount_id > final_id:
    final_id = amount_id
numbers = list(range(start_id, final_id, -1))
fails = 0
success_rate = [0, 0]
portraits_found = 0
valid_id = []

while len(numbers) > 0:

    sleep_time = delay - time.time() + last_time
    if sleep_time > 0:
        time.sleep(sleep_time)
    last_time = time.time()

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))

    #Just comment this section out if not using a VPN
    #if s.getsockname()[0] == "10.2.0.2":
        #s.close()
    #else:
        #print(F"VPN Broke: {s.getsockname()[0]}, saving and quitting at id: {numbers[0]}")
        #s.close()
        
        #print(F"{valid_id = }")
        #quit()

    try:
        with urllib.request.urlopen(f'https://ice.puzzlepirates.com/yoweb/gallery/portrait.wm?itemid={numbers[0]}') as f:
            page = f.read().decode('utf-8')

        if not deleted_message in page:
            portraits_found += 1
            valid_id.append(numbers[0])

        fails = 0
        success_rate[0] += 1
        print(F"{numbers[0]} scanned, {success_rate = }, {portraits_found = }, portrait_IDs = {valid_id}")
        numbers.pop(0)

    except urllib.error.URLError as e:
        print(e.reason)
        print(F"Retrying portrait ID {numbers[0]}")
        fails += 1
        success_rate[1] += 1

        if fails > fail_allowance:
            print(f"{fail_allowance+1} blocks in a row, saving and quitting at id: {numbers[0]}")
            print(F"{valid_id = }")
            quit()

        continue
    

print(F"{valid_id = }")
print("Finished")