MQ3pin = 'A0';
disp('start');

% Define the duration of the data acquisition in seconds
symbolDuration = 5;
symbolsSent = 5; % Number of symbols to receive
totalDuration = symbolsSent * symbolDuration;
derivativeThreshold = 1; % Define the threshold value

% Initialize variables for plotting and decoding
voltageData = [];
timeData = [];
decodedSignal = [];
currentIntervalStart = 0;

signalDecoded = false;

% Set up the plot
figure;
subplot(2, 1, 1);
h1 = plot(NaN, NaN);
ylim([0 5]); % Assuming the voltage range is 0 to 5V
xlim([0 symbolDuration]);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Sensor Voltage');

subplot(2, 1, 2);
h2 = plot(NaN, NaN);
ylim([-5 5]); % Derivative range
xlim([0 symbolDuration]);
xlabel('Time (s)');
ylabel('dV/dt (V/s)');
title('First Derivative of Voltage');

startTime = tic;
currentTime = toc(startTime);

while currentTime < totalDuration
    while currentTime < (length(signalDecoded) + 1) * symbolDuration
        currentTime = toc(startTime);
        currentVoltage = readVoltage(a, MQ3pin);
        
        timeData = [timeData, currentTime];
        voltageData = [voltageData, currentVoltage];
        
        % Update the plots
        set(h1, 'XData', timeData, 'YData', voltageData);
        drawnow;
        
        % Wait a short time before the next reading
        pause(0.01); % Adjust the pause duration as needed
    end

    % Calculate the derivative of voltage data with respect to time and plot
    derivativeData = diff(voltageData) ./ diff(timeData);
    set(h2, 'XData', timeData, 'YData', derivativeData);
    drawnow;
    
    % Check if the first derivative exceeds the threshold within the current interval
    if any(derivativeData > derivativeThreshold)
        printf('Detected 1');
        decodedSignal = [decodedSignal, 1];
    else
        printf('Detected 0');
        decodedSignal = [decodedSignal, 0];
    end
    
    % reset time and voltage data for the new symbol
    timeData = [];
    voltageData = [];
    derivativeData = [];
end

% Display the decoded signal
disp('Decoded Signal:');
disp(decodedSignal);
