# Frequently asked questions...

## GPIO pin for DC-DC converter switching

During trials pin_boost was set to 1 to avoid false switching of the converter during the boot process.

## Why not use FETs for DC-DC converter switching?

The bipolar transistor design was chosen so that it worked down to 2.5V supply, worked to mean that both transistors were driven
to saturation with available voltage and current from the GPIO pin. Whilst is is not intended to operate below 3.4/3,3V, it provides a safety margin.
 




***
