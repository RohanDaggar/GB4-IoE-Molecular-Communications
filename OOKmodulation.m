pulseWidth = 0.1; % Time of spray for a 1
symbolInterval = 10; % Time window of each symbol
n = 10; % Number of symbols to send

data = randi(2, n, 1)-1;
fprintf('Data to send: %s\n', num2str(data'));

for i = 1:length(data)
    bit = data(i);
    if bit == 1
        fprintf('Sending 1\n');
        controlSprayer(a, pulseWidth);
        pause(symbolInterval-pulseWidth);
    else
        fprintf('Sending 0\n');
        pause(symbolInterval);
    end
end
