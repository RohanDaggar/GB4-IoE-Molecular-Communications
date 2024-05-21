lowPulseWidth = 0.1; % Time of spray for 0
highPulseWidth = 0.5; % Time of spray for 1
symbolInterval = 15; % Time window of each symbol

data = [0 1 0 1];

for i = 1:length(data)
    bit = data(i);
    if bit == 0
        fprintf('Sending 0\n');
        controlSprayer(a, lowPulseWidth);
        pause(symbolInterval-lowPulseWidth);
    elseif bit == 1
        fprintf('Sending 1\n');
        controlSprayer(a, highPulseWidth);
        pause(symbolInterval-highPulseWidth);
    else
        fprintf('Invalid Input\n');
        pause(symbolInterval);
    end
end
