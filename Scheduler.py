#main logic to recieve configuration information and execute commands on schedule
#Infinitly running loop, checks for updated schedule every minute, then determines
#appropriate actions

#schedule format: 
# 1(access flag) {"status":status , "schedule": {
#					date:[STATE, STATE, STATE, ...], 
#					date:[STATE, STATE, ...], 
#					... }
#				 }
#
#	status : enabled/disabled
#
# 	STATE = {"code":code, "start":time, "end":time,
#							"progress":prog}
# 	
#	code: A(A on, D off) 0000(channel) 00(volume)
# 	
# 	prog = {0 (pending), 1(active), 2(finished)}	
#	

import json
import pytz
import time
import os
from datetime import datetime




def main():

	#create first time routine that turns tv off
	mainLoop("testFile.txt")




def mainLoop(file):
	while True:
		
		time.sleep(2)
		# read file -> make local copy, set accessed flag to 0
		f = open(file, "r")
		text = f.read()
		f.close()
		Data = text[2:]
		
		if text[0] == "1":
			tempText = "0 " + Data
			f = open(file, "w")
			f.write(tempText)
			f.close()

		try:
			JData = json.loads(Data)
		except ValueError:
			#print("couldn't parse Json")
			continue

		#check if status is enabled
		status = JData.get('status', 0)
		#if an error is encountered (badly formated file)
		#it just loops back to prevent crash
		if status == 0:
			continue

		if status == "disabled":
			#print("disabled")
			continue




		#Find current task
		schedule = JData.get('schedule', 0)
		if schedule == 0:
			continue

		tz_BA = pytz.timezone('America/Buenos_Aires')
		todayObj = datetime.now(tz_BA)
		today = todayObj.strftime("%d/%m/%Y")

		#make sure there's a schedule for today
		if not (schedule.get(today, False)):
			#print("nothing for today")
			continue

		Tasks = schedule.get(today)

		#loop through the tasks until we find current one
		found = False;
		foundIndex = 0;
		for i in range(0, len(Tasks)):
			currentTask = Tasks[i]
			start = currentTask.get("start")
			start_DT = tz_BA.localize(datetime.strptime(today+" "+start, "%d/%m/%Y %H:%M"))
			end = currentTask.get("end")
			end_DT = tz_BA.localize(datetime.strptime(today+" "+end, "%d/%m/%Y %H:%M"))

			if (start_DT < todayObj)and(todayObj < end_DT):
				found = True
				foundIndex = i
				break

		if not found:
			#print("nothing to do right now")
			continue

		#check if already active
		if currentTask.get("progress") == 1:
			#print("current task already in progress")
			continue

		#get code and send approriate commands to queue
		code = str(currentTask.get("code"))

		#modify the currentTask to have progress = 1
		mod = {"progress":1}
		currentTask.update(mod)

		#update the Tasks list
		Tasks[foundIndex] = currentTask

		#update the schedule dict
		schedule.update({today: Tasks})

		#update Jdata
		JData.update({"schedule": schedule})

		#make sure file hasn't changed since beginning of loop
		f = open(file, "r")
		text = f.read()
		f.close()
		if text[0] == "1":
			#print('oops, file changed while processing it')
			continue

		Data = json.dumps(JData)
		text = "0 " + Data
		f = open(file, "w")
		f.write(text)
		f.close()

		executeCode(code)




def executeCode(code):
	codeArray = code.split()

	if codeArray[0] == 'D':
		control_powerOFF()
	else:
		control_on(codeArray[1], codeArray[2])


def control_on(channel, volume):
	#check if tv is on, then change channel accordingly and set volume
	control_powerON()
	control_setChannel(channel)
	control_setVolume(volume)

	#print ("turning tv on to channel " + channel + " at volume "+volume)



def control_powerOFF():
	os.system('irsend SEND_START RC64 KEY_POWEROFF')
	time.sleep(1.5)
	os.system('irsend SEND_STOP RC64 KEY_POWEROFF')

	os.system('irsend SEND_START sonyTV3 KEY_power2')
	time.sleep(1.5)
	os.system('irsend SEND_STOP sonyTV3 KEY_power2')



def control_powerON():
	#send ir to power on
	os.system('irsend SEND_START RC64 KEY_POWERON')
	time.sleep(1.5)
	os.system('irsend SEND_STOP RC64 KEY_POWERON')

	os.system('irsend SEND_START sonyTV3 KEY_POWER')
	time.sleep(1.5)
	os.system('irsend SEND_STOP sonyTV3 KEY_POWER')



def control_setChannel(channel):
	for i in range(0, len(channel)):
		os.system('irsend SEND_ONCE RC64 KEY_'+channel[i])
		time.sleep(0.15)



def control_setVolume(volume):
	#first set volume to 0
	os.system('irsend SEND_START sonyTV3 KEY_volumedown')
	time.sleep(4)
	os.system('irsend SEND_STOP sonyTV3 KEY_volumedown')
	for j in range (0, volume-1):
		#send ir blast for volume up
		os.system('irsend SEND_ONCE sonyTV3 KEY_volumeup')
		time.sleep(1/5)

		


main()
