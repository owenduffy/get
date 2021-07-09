print("in MB1242")
require("cfg-MB1242")

MAXIMUM_DISTANCE=20
-- minimum reading interval with 20% of margin
READING_INTERVAL=math.ceil(MAXIMUM_DISTANCE*2/340*1000*1.2)
-- number of readings in set
NUM_READINGS=8

MB1242_addr=0x70
delay=100
bid=0
readings={}
temperature=20
velocity=331.3*(1+temperature/273.15)^0.5

function write_reg(bid,dev_addr,reg_addr,data)
    i2c.start(bid)
    i2c.address(bid, dev_addr, i2c.TRANSMITTER)
    if(reg_addr~=nil) then
      i2c.write(bid, reg_addr)
    end
    c = i2c.write(bid, data)
    i2c.stop(bid)
    return c
end

function read_reg(bid,dev_addr,reg_addr,count)
    i2c.start(bid)
    if(reg_addr~=nil) then
      i2c.address(bid,dev_addr,i2c.TRANSMITTER)
      i2c.write(id,reg_addr)
      i2c.stop(bid)
      i2c.start(bid)
    end
    i2c.address(bid,dev_addr,i2c.RECEIVER)
    c=i2c.read(bid,count)
    i2c.stop(bid)
    return c
end

function cbMB1242_read(bid,dev_addr,reg_addr,count)
  c=read_reg(bid,dev_addr,nil,2)
  echo_time=(c:byte(1)*256+c:byte(2))/100/340*2
  calculate(echo_time)
end

function calculate(echo_time)
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
  htmr=tmr.create()
  htmr:alarm(READING_INTERVAL,tmr.ALARM_AUTO,function()cbMB1242_read(bid,MB1242_addr,nil,1)end)
end



i2c.setup(bid,pin_sda,pin_scl,i2c.FAST)
i2c.start(bid)
if(i2c.address(bid, MB1242_addr, i2c.TRANSMITTER)) then
  print("xx:",xx)
  --write start read command (81)
  count=write_reg(bid,MB1242_addr,null,81)
  print(count, " bytes written")
--  tmr.create():alarm(delay,tmr.ALARM_SINGLE,function()cbMB1242_read(bid,MB1242_addr,nil,2)end)
  --get temperature
  local t=require("ds18b20")
  t:read_temp(cbtemp_done,pin_ds18b20,t.C,1)
else
  print("No ACK")
end
