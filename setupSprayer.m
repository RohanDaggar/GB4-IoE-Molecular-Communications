% This sets up the arduino on object a and configures the pin to active the
% spray bottle
a = arduino;
configurePin(a, 'D9', 'DigitalOutput');