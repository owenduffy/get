# A simple IoT tank level monitor for NodeMCU / Lua which measures and and submits level by [RESTful API](https://en.wikipedia.org/wiki/Representational_state_transfer).

![Block diagram](get02.png "Block diagram")

Above is a block diagram of the telemetry system using a 4-20mA soil temperature sensor.

To use the code, copy init.default.lua to init.lua, and nodevars.default.lua to nodevars.lua and customise the latter to suit your needs.

![Flow chart](get01.png "Flow chart")

The code supports HTTP GET and POST.

Example URLs for the REST host are:

* Thingspeak: http://api.thingspeak.com/update
* Emoncms: http://emoncms.org/input/post


Edit the httpgetreq() definitition in init.lua to suit your REST host, eg:

```lua
function httpreq() 
  req=rest_url.."?api_key="..apikey.."&field3="..temperature.."&field4="..humidity.."&field5="..qnh.."&field6="..ain
  body=""
  print("req:"..req.."\nbody:"..body)
  return req,body
end
```
 
GET requests are usually fairly easy to get going, but you may find the RESTED add-in for Firefox and Chrome to be useful, also http://httpbin.org for testing.

The deep sleep function used depends on an external connection which you must make for it to work properly: connect a SB or germainium diode anode to RST, cathode to GPIO16 (D0).
 
Tested on float firmware:

```
NodeMCU 3.0.0.0 built on nodemcu-build.com provided by frightanic.com
	branch: release
	commit: d4ae3c364bd8ae3ded8b77d35745b7f07879f5f9
	release: 
	release DTS: 202105102018
	SSL: true
	build type: float
	LFS: 0x0 bytes total capacity
	modules: adc,bit,bme280_math,dht,encoder,file,gpio,http,i2c,mdns,mqtt,net,node,ow,sntp,spi,tmr,uart,wifi,tls
 build 2021-06-10 08:45 powered by Lua 5.1.4 on SDK 3.0.1-dev(fce080e)
```

# Programming a bare ESP8266 board

You need to build and download a firmware module with all the above modules, and install it on the ESP8266 so that it becomes a NodeMCU.
When you start it, it will build an empty filesystem.

Then upload all of the project *.lua files to the file system, [Esplorer](https://github.com/4refr0nt/ESPlorer/releases) is recommended.

# Configuration of a loaded NodeMCU

After loading all the necessary files onto the NodeMCU, it needs configuring.

Press the reset button and hold GPOI0 low for 5s. Then connect to the AP created and connect to the web server at 192.168.1.1 and fill in
the configuration form and save it. The defaults for this form are in init.lua.

## Devkit v1.0 compatible boards and Esplorer

This is easily done on Devkit v1.0 comptabitle boards with Esplorer where you hit and release RTS and hold DTR for 5s.

## Other

Hit reset and then ground D3 for 5s.

# Calibration of 4-20mA input
There are a lot of ways to go about calibration and scaling of the output, and the code has been written to be flexible.

Sources of error include:
- Pt100 probe and wiring;
- RTD to 4-20mA converter; and
- 4-20mA burden and ADC calibration.

Useful calculator tool: [Slope - intercept calibration constants calculator](https://owenduffy.net/calc/slope-intercept-cal.htm)

![Calibration example](calex01.png "Calibration example")


# FAQ

[FAQ](FAQ.md).


***
