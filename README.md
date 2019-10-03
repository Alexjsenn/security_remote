# Security Remote
Growing up in a city with high levels of break-ins, we used strategies to make it seem as though someone was in the house when we were out. One of the biggest was leaving the TV on. However, this summer as my family and I left for a two week vacation, I realized we needed a better solution. I needed a way to remotely control the TV. I thus developed a system that is compromised of two parts:
1) Raspberry Pi running an basic apache server, with an IR emmitter connected to control the TV and cable box
2) Mobile app that can create and modify a schedule to control the TV

## Raspberry Pi Server
### Remote Control with IR
An IR emitter is connected to the GPIO ports on the Pi. Using LIRC, a package to decode and send IR signals, I am able to record the signals sent by the TV and cable box. Then I can send these commands from a Python script. The schedule is stored in a Json file, which the scheduler.py can then read and perform the appropriate commands and the right times.

### Server and API
The Pi has a default installation of Apache running on it. Using port forwarding and a DDNS service the server can be accessed from anywhere in the world. I then created PHP files to implement a simple API with GET and POST operations. This enables the app to request the current schedule, modify it, then send it back.


## Mobile App
Using the Flutter framework, I developed an cross platform app that allows users to create, delete and modify events, as well as turning on and off the system.

**Creating an event**                     
![Creating an event](/screenshots/create-event.png)

**Viewing events**                         
![View events](/screenshots/view-events.png)

**Deleting events with long press on card**
![Delete events](/screenshots/delete-events.png)
