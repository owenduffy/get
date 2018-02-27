# Frequently asked questions...

## DHT / AM2320 GPIO pin use

During trials the AM3220 seems to be triggered during traffic on D4 during boot, and it showed up in testing that a double read seemed
not necessary. (This problem has not been notice in many projects using DHT22, and Wemos produces a DHT22 shield that connects to D4.)
The ESP8266 NodeMCU is not like most microcontrollers that boot up will all GPIO pins in high impedance input mode, there
is traffic on GPIO pins during boot and boot can be disrupted by input on some pins.

When you read the AM2320, it plays back the last measurment, and starts a new measurement and stores the value. If the interval between
reads is large, you really need to read twice to get the current temp etc.

Now it turned out that the AM2320 would sometimes lock up, possibly a result from the traffic during boot, soit has been moved to D5
and the double read becomes necessary and is reinstated. There is a signifant delay between the reads to allow for the measurement
cycle of the AM2320 (2s).

## GPIO pin for DC-DC converter switching

During trials pin_boost was set to 1 to avoid false switching of the converter during the boot process.

## Why not use FETs for DC-DC converter switching?

The bipolar transistor design was chosen so that it worked down to 2.5V supply, worked to mean that both transistors were driven
to saturation with available voltage and current from the GPIO pin. Whilst is is not intended to operate below 3.4/3,3V, it provides a safety margin.
 




***
