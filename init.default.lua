--copy to init.lua and edit cfgdefs below
--the values correspond to cfgvars
cfgdefs={
"",
"",
"Tank1",
"1",
"4",
"3",
"600",
"0",
"500",
"0",
"1",
"%0.1f",
"http://api.thingspeak.com/update",
""
}
--no need for changes below here
cfgvars={
"wifi_SSID",
"wifi_password",
"id",
"pin_boost"
"pin_scl",
"pin_sda",
"meas_period"
"altitude",
"meas_delay_ms"
"meas_intercept"
"meas_slope",
"meas_fmt",
"rest_url",
"apikey",
}

time_between_sensor_readings = 600000

function transform()
  dofile("csinterp.lua")
  if level<0 then level=0 end
  volume=csinterpolate("dam",level)/1000
  volume=string.format(meas_fmt,volume)
  print("Volume: ",volume)
end

function httpreq() 
  req=rest_url.."?id="..id
--  transform()
--  req=rest_url.."?api_key="..apikey.."&field1="..volume.."&field2="..temperature.."&field3="..humidity
  body=""
  print("req:"..req..":\nbody:"..body..":")
  return req,body
end

print("\n\nHold Pin00 low for 1s to stop boot.")
print("\n\nHold Pin00 low for 5s for config mode.")
tmr.delay(1000000)
if gpio.read(3) == 0 then
  print("Release to stop boot...")
  tmr.delay(4000000)
  if gpio.read(3) == 0 then
    print("Release now (wifi cfg)...")
    print("Starting wifi config mode...")
    dofile("wifi_setup.lua")
    return
  else
    print("...boot stopped")
    return
    end
  end

print("Starting...")
if pcall(function ()
    print("Open config")
--    dofile("config.lc")
    dofile("config.lua")
    end) then
  dofile("app.lua")
else
  print("Starting wifi config mode...")
  dofile("wifi_setup.lua")
end
