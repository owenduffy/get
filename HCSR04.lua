print("in HCSR04")
require("cfg-HCSR04")

TRIG_INTERVAL=15 -- us (minimum is 10, see HC-SR04 documentation)
MAXIMUM_DISTANCE=20
-- minimum reading interval with 20% of margin
READING_INTERVAL=math.ceil(((MAXIMUM_DISTANCE*2/340*1000)+TRIG_INTERVAL)*1.2)
-- number of readings in set
NUM_READINGS=8

-- initialize global variables
time_start=0
time_stop=0
distance=0
readings={}
temperature=20
velocity=331.3*(1+temperature/273.15)^0.5

-- send trigger signal
function trigger()
  gpio.write(pin_trig, gpio.HIGH)
  tmr.delay(TRIG_INTERVAL)
  gpio.write(pin_trig, gpio.LOW)
  while(gpio.read(pin_echo)==0) do end
  time_start = tmr.now()
  while(gpio.read(pin_echo)==1) do end
  time_stop = tmr.now()
  calculate()
end

function calculate()
  local echo_time=(time_stop-time_start)/1000000
  if echo_time>0 then
    table.insert(readings,echo_time)
  end
  if #readings>=NUM_READINGS then
    htmr:stop()
    gpio.write(pin_boost,gpio.LOW) --boost off
    table.sort(readings)
    --average middle n-4
    local i
    for k,v in pairs(readings) do print(v) end
    for i=1,2 do
      table.remove(readings,1) --remove first entry
      table.remove(readings) --remove last entry
    end
    echo_time=0
    for k,v in pairs(readings) do echo_time=echo_time+v end
    echo_time=echo_time/table.getn(readings)
    distance=echo_time*velocity/2
    node.task.post(cbdistance_done)
    package.loaded[dist_sensor]=nil
  end
end

function cbtemp_done(temps)
   for addr, temp in pairs(temps) do
    print(string.format("Sensor %s: %s C",
    ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8)), temp))
    temperature=temp
    break --only first
  end
  velocity=331.3*(1+temperature/273.15)^0.5
--  velocity=340
  print("vel :",velocity)
  print("temp :",temperature)
  -- module can be released when it is no longer needed
  t=nil
  package.loaded["ds18b20"]=nil
  require(dist_sensor)
end

-- init pins
gpio.mode(pin_boost,gpio.OUTPUT)
if (deb>0) then 
  gpio.write(pin_boost,gpio.HIGH) --boost on
else
  gpio.write(pin_boost,gpio.LOW) --boost off
end
gpio.mode(pin_trig,gpio.OUTPUT)
gpio.mode(pin_echo,gpio.INPUT,gpio.PULLUP)

--get temperature
local t=require("ds18b20")
t:read_temp(cbtemp_done,pin_ds18b20,t.C,1)

-- trigger timer
htmr=tmr.create()
htmr:alarm(READING_INTERVAL,tmr.ALARM_AUTO,trigger)
