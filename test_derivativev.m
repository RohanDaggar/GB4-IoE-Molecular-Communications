% This script reads the voltage and plots the derivative and integral of the voltage over time.
% make sure a is set to the arduino object
% a = arduino
MQ3pin = 'A0'; % MQ3 pin on arduino to read input voltage
disp('MQ3 warming up!');
pause(1); % Allow the MQ3 to warm up for 1 second

% Number of readings
numSybmols = 4; % Number of symbols to be read
waitTime = 0.01; % Time to wait between readings in seconds aka sampling time
symbolInterval = 5; % The time window for which a symbol is sent in
totalTime = numSybmols * symbolInterval;

% Initialize variables for plotting
voltageData = zeros(1, numReadings);
timeData = zeros(1, numReadings);
derivativeData = zeros(1, numReadings);

% Set up the plot
figure;
subplot(3, 1, 1);
h1 = plot(timeData, voltageData);
ylim([0 3]); % Assuming the voltage range is 0 to 5V
xlim([0 totalTime]);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Sensor Voltage');

subplot(3, 1, 2);
h2 = plot(timeData, derivativeData);
ylim([-5 5]); % Adjust as needed based on expected derivative range
xlim([0 totalTime]);
xlabel('Time (s)');
ylabel('dV/dt (V/s)');
title('First Derivative of Voltage');

subplot(3, 1, 3);
% h3 = plot(timeData, derivativeData);
ylim([-5 5]); % Adjust as needed based on expected integral range
xlim([0 totalTime]);
xlabel('Time (s)');
ylabel('int V (Vs)');
title('First Integral of Voltage');


startTime = tic;
i = 0;
while toc(startTime) <= totalTime
    i = i + 1;
    currentTime = toc(startTime);
    voltage = readVoltage(b, MQ3pin); % Read the sensor value from analog pin A0 and record the time
    % voltage = 0.5 + 1 * rand(); % generate a random number between 0.5 and 1.5
    
    % Update the voltage data
    voltageData(i) = voltage;
    timeData(i) = currentTime;
    
    % Calculate the first derivative if we have enough data points
    if i > 1
        derivativeData(i) = (voltageData(i) - voltageData(i-1)) / (timeData(i) - timeData(i-1));
    else
        derivativeData(i) = 0; % First point derivative is zero
    end
    
    % Display the sensor value
    fprintf('Sensor Value: %.2f\n', voltage);
    
    % Update the plots at intervals of 5 to reduce lag
    if mod(i, 1) == 0
        set(h1, 'XData', timeData(1:i), 'YData', voltageData(1:i));
        set(h2, 'XData', timeData(1:i), 'YData', derivativeData(1:i));
        drawnow;
    end
    
    % Wait a short time before the next reading
    pause(waitTime);
end
