print("in 4-20mA")
require("cfg-4-20mA")

-- 4-20mA sensor
function get_420()
ain=adc.read(0)
print("ain: ",ain)
end

function get_bme280()
s:read(altitude)
tmr.delay(150*1000) --wait for read
temp,qfe,humi,qnh=s:read(altitude)
if temp~=nil then
  temperature=string.format("%0.1f",temp)
  qfe=string.format("%0.1f",qfe)
  humidity=string.format("%0.1f",humi)
  qnh=string.format("%0.1f",qnh)
  print("Temperature: "..temperature.."C")
  print("Humidity: "..humidity.."%")
  print("QFE: "..qfe.."hPa")
  print("QNH: "..qnh.."hPa")
  ----node.task.post(cbain_done)
end
  package.loaded["bme280"]=nil
end
bid=0
temperature=0
humidity=0
i2c.setup(bid,pin_sda,pin_scl,i2c.SLOW)
gpio.write(pin_boost,gpio.HIGH) --boost on
tmr.delay(meas_delay_ms*1000) --wait for stability
get_420()
ain=ain*meas_slope+meas_intercept
s=require('bme280').setup(bid,nil,nil,nil,nil,nil,BME280_NORMAL_MODE)
if s==nil then
  print("Failed BME280 setup.")
else
  if not pcall(get_bme280) then
    print("Error: get_bme280() raised an error")
  end
end
gpio.write(pin_boost,gpio.LOW) --boost off
    print("postit")
node.task.post(cbain_done)
package.loaded[ain_sensor]=nil
