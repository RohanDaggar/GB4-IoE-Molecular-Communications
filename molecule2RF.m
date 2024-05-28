% Ensure arduino is bound to a with a=arduino
MQ3pin = 'A0'; % MQ3 pin of gas sensor
dronePin = 'D10'; % pin connected to the drone controller

% Initialize variables for plotting and decoding
voltageData = [];
timeData = [];
derivativeData = [];
decodedSignal = [];
currentIntervalStart = 0;
intervalDuration = 3; % 3-second interval
numberOfSymbols = 20; % Number of symbols to receive
totalDuration = numberOfSymbols * intervalDuration;
signalDecoded = false;

% Set up the plot
figure;
subplot(2, 1, 1);
h1 = plot(NaN, NaN);
ylim([0 5]); % Assuming the voltage range is 0 to 5V
xlim([0 totalDuration]);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Sensor Voltage');

subplot(2, 1, 2);
h2 = plot(NaN, NaN);
ylim([-5 5]); % Adjust as needed based on expected derivative range
xlim([0 totalDuration]);
xlabel('Time (s)');
ylabel('dV/dt (V/s)');
title('First Derivative of Voltage');


% The detection algorithm will wait for a 1 signal
% It will then detect the next symbol
% If it is a 0, the drone will go up
% If it is a 1, the drone will go down
% It will then wait for the next 1 signal.

while True
    startTime = tic;
    while toc(startTime) < totalDuration
        % Read the sensor value from analog pin A0
        voltage = readVoltage(a, MQ3pin);
        
        % Update the voltage data and time data
        currentTime = toc(startTime);
        voltageData = [voltageData, voltage];
        timeData = [timeData, currentTime];
        
        % Calculate the first derivative if we have enough data points
        if length(voltageData) > 1
            derivativeData = [derivativeData, (voltageData(end) - voltageData(end-1)) / (timeData(end) - timeData(end-1))];
        else
            derivativeData = [derivativeData, 0]; % First point derivative is zero
        end
        
        % Check if the first derivative exceeds 1 within the current interval
        if currentTime >= currentIntervalStart + intervalDuration
            if ~signalDecoded
                decodedSignal = [decodedSignal, 0]; % Decoded as 0
                fprintf('0\n');
            end
            currentIntervalStart = currentTime;
            signalDecoded = false;
        end
        
        if derivativeData(end) > 1
            if ~signalDecoded
                decodedSignal = [decodedSignal, 1]; % Decoded as 1
                fprintf('1\n');
                signalDecoded = true;
                currentIntervalStart = currentTime; % Skip to the next interval
            end
        end
        
        % Update the plots
        set(h1, 'XData', timeData, 'YData', voltageData);
        set(h2, 'XData', timeData, 'YData', derivativeData);
        drawnow;
        
        % Wait a short time before the next reading
        pause(0.01); % Adjust the pause duration as needed
    end

    % Display the decoded signal
    disp('Decoded Signal:');
    disp(decodedSignal);

end