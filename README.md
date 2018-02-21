# A simple IoT tank level monitor for NodeMCU / Lua which measures and and submits level by [RESTful API](https://en.wikipedia.org/wiki/Representational_state_transfer).

![Block diagram](tanklevel02.png "Block diagram")

Above is a block diagram of the telemetry system.

To use the code, copy init.default.lua to init.lua, and nodevars.default.lua to nodevars.lua and customise the latter to suit your needs.

![Flow chart](tanklevel01.png "Flow chart")

The code supports HTTP GET and POST.

Example URLs for the REST host are:

* Thingspeak: http://api.thingspeak.com/update
* Emoncms: http://emoncms.org/input/post


Edit the httpgetreq() definitition in init.lua to suit your REST host, eg:
 
GET requests are usually fairly easy to get going, but you may find the RESTED add-in for Firefox and Chrome to be useful, also http://httpbin.org/get for testing.

The deep sleep function used depends on an external connection which you must make for it to work properly: connect a SB or germainium diode anode to RST, cathode to GPIO16 (D0).
 
Tested on:
NodeMCU custom build by frightanic.com
    branch: master
    commit: 5073c199c01d4d7bbbcd0ae1f761ecc4687f7217
    SSL: true
    modules: adc,bit,dht,encoder,file,gpio,http,mqtt,net,node,ow,spi,tmr,uart,wifi,tls
 build  built on: 2018-02-14 02:37
 powered by Lua 5.1.4 on SDK 2.1.0(116b762)

# Programming a bare ESP8266 board

You need to build and download a firmware module with all the above modules, and install it on the ESP8266 so that it becomes a NodeMCU.
When you start it, it will build an empty filesystem.

Then upload all of the project *.lua files to the file system, Esplorer is recommended.

# Configuration of a loaded NodeMCU

After loading all the necessary files onto the NodeMCU, it needs configuring.

Press the reset button and hold GPOI0 low for 5s. Then connect to the AP created and connect to the web server at 192.168.1.1 and fill in
the configuration form and save it. The defaults for this form are in init.lua.

## Devkit v1.0 compatible boards and Esplorer

This is easily done on Devkit v1.0 comptabitle boards with Esplorer where you hit and release RTS and hold DTR for 5s.

## Other

Hit reset and then ground D3 for 5s.

# Calibration
There are a lot of ways to go about calibration and scaling of the output, and the code has been written to be flexible. Here is a simple example.

Lets say the tank holds 15,000l when full, is 3m deep, and we are using a 4m 4-20mA sensor, and lets say you want to display litres in the tank.

## Gather calibration raw values

Start by configuring the device to connect to the display service, wet meas_offset=0 and meas_divisor=1.

Set the sensor to minimum depth, write down the displayed value (A) and minimum depth (in intended display units) (B).

Set the sensor to some other depth, write down the displayed value (C) and that depth (in intended display units) (D).

In our example, A=19,900,000, B=0, C=47,400,000, D=12,000.

It is possible with this scheme to set a non-zero base to the displayed value, and to scale the displayed value to end-user units,
and the calibration process offsets ettors in the sensor, ESP8266 a0 voltage divier and MCU voltage reference.

## Calculate calibration constants

meas_divisor=(C-A)/D=2,292

meas_offset=A-meas_divisor/2=19,898,854

## Set calibration constants

Start configuring the device to connect to the display service, and set meas_offset and meas_divisor to the new calculated values.

***
