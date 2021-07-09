-- Remember to connect GPIO16 (D0) and RST for deep sleep function,
-- better though a SB diode anode to RST cathode to GPIO16 (D0).

--# Settings #
require("nodevars")
--# END settings #
ver=0.2
print("Tanklevel app.lua v"..ver)

function cbdistance_done()
print("in done measuring")
  print("Distance: "..string.format(meas_fmt, distance).." Readings: "..#readings)
  level=distance*meas_slope+meas_intercept
  swf()
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

require(dist_sensor)
