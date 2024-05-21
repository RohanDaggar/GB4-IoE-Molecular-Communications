function controlSprayer(a, pulseWidth)
% This function turns on the sprayer for a defined pulse width
writeDigitalPin(a, 'D9', 1);
pause(1/100);
writeDigitalPin(a, 'D9', 0);
pause(pulseWidth);
writeDigitalPin(a, 'D9', 1);
pause(1/100);
writeDigitalPin(a, 'D9', 0);

end