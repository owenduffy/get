print("in 4-20mA")
require("cfg-4-20mA")
readings={}

-- 4-20mA sensor
function get_420()
gpio.write(pin_boost,gpio.HIGH) --boost on
tmr.delay(meas_delay_ms*1000) --wait for stability
distance=adc.read(0)
gpio.write(pin_boost,gpio.LOW) --boost off
--print("Distance: ",distance)
table.insert(readings,distance)
node.task.post(cbdistance_done)
package.loaded[dist_sensor]=nil
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
----node.task.post(cbdistance_done)
  package.loaded["bme280"]=nil
end
bid=0
i2c.setup(bid,pin_sda,pin_scl,i2c.FAST)
s=require('bme280').setup(bid,nil,nil,nil,nil,nil,BME280_FORCED_MODE)
if s==nil then
  print("Failed BME280 setup.")
else
  get_bme280()
end
get_420()
