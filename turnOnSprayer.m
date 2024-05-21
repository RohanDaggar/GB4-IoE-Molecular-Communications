% If the spray bottle is off, this script turns it on
writeDigitalPin(a, 'D9', 1);
pause(1.3);
writeDigitalPin(a, 'D9', 0);
pause(0.1);
writeDigitalPin(a, 'D9', 1);
pause(0.1);
writeDigitalPin(a, 'D9', 0);