-- Remember to connect GPIO16 (D0) and RST for deep sleep function,
-- better though a SB diode anode to RST cathode to GPIO16 (D0).

--# Settings #
dofile("nodevars.lua")
--# END settings #
temperature = 0
humidity = 0
ver=0.2
print("Tanklevel app.lua v"..ver)

-- 4-20mA sensor
function get_420()
gpio.write(pin_boost,gpio.HIGH) --boost on
tmr.delay(meas_delay_ms*1000) --wait for stability
level=adc.read(0)
gpio.write(pin_boost,gpio.LOW) --boost off
level=meas_slope*level+meas_intercept
--level=string.format(meas_fmt,level)
print("Level: "..level)
end

function get_bme280()
temp,qfe,humi,qnh=s:read(altitude)
temperature=string.format("%0.1f",temp)
--qfe=string.format("%0.1f",qfe)
humidity=string.format("%0.1f",humi)
--qnh=string.format("%0.1f",qnh)
print("Temperature: "..temperature.."C")
print("Humidity: "..humidity.."%")
--print("QFE: "..qfe.."hPa")
--print("QNH: "..qnh.."hPa")
end

function get_sensor_Data()
  get_420()
  if s~=nil then
    get_bme280()
  end
end

function swf()
--  print("wifi_SSID: "..wifi_SSID)
--  print("wifi_password: "..wifi_password)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,cbsrest)
  wifi.setmode(wifi.STATION) 
  wifi.setphymode(wifi_signal_mode)
  if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
  end
  wifi.sta.sethostname(wifi_hostname)
  wifi.sta.config({ssid=wifi_SSID,pwd=wifi_password})
  print("swf done...")
end

function cbsrest()
  print("\ncbsrest:")
  print(tmr.now())
  print("wifi.sta.status()",wifi.sta.status())
  if wifi.sta.status() ~= 5 then
    print("No Wifi connection...")
  else
    print("WiFi connected...")
  end
  --send measurements
  req,body=httpreq()
  if(body=="") then
    http.get(req,nil,cbhttpdone)
  else
    http.post(req,nil,body,cbhttpdone)
  end
  print("cbsrest done...")
end

function cbhttpdone(code,data)
  if (code<0) then
    print("HTTP request failed")
    print(code,data)
  else
    print(code,data)
  end
  rtmr=tmr.create()
  rtmr:alarm(500,tmr.ALARM_SINGLE,cbslp)
end

function cbslp()
  print(tmr.now())
  if (meas_period*1000000-tmr.now()+8100>10000000) then
    node.dsleep(meas_period*1000000-tmr.now()+8100,2)
  else
    print("Value meas_period too small")
  end             
end

print("app starting...")
--watchdog will force deep sleep loop if the operation somehow takes too long
tmr.create():alarm(30000,1,cbslp)

-- init pins
gpio.mode(pin_boost,gpio.OUTPUT)
if (deb>0) then 
  gpio.write(pin_boost,gpio.HIGH) --boost on
else
  gpio.write(pin_boost,gpio.LOW) --boost off
end
i2c.setup(0,pin_sda,pin_scl,i2c.SLOW)
s=require('bme280').setup(0,nil,nil,nil,nil,nil,BME280_FORCED_MODE)
--print(s)
if s==nil then
  print("Failed BME280 setup.")
else
  get_bme280()
end
--read sensor before wifi startup for less ADC noise
get_420()
--setup wifi
swf()
print("app running...")
