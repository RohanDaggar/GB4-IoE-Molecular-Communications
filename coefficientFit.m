% used to fit co efficients of impulse response for 6 trials

MQ3pin = 'A0';
disp('MQ3 warming up!');
pause(2); % Allow the MQ3 to warm up for 2 seconds

numReadings = 50; % Number of readings
d = 0.15; % distance from transmitter to sensor

% Initialize variables for plotting
voltageData = zeros(1, numReadings);
timeData = zeros(1, numReadings);

% Set up the plot
figure;
h = plot(timeData, voltageData);
ylim([0 5]); % Assuming the voltage range is 0 to 5V
xlim([0 3]);
xlabel('Time (s)');
ylabel('Voltage (V)');

controlSprayer(a, 0.1) % spray for 100 ms
startTime = tic;

for i = 1:numReadings
    % Read the sensor value from analog pin A0
    voltage = readVoltage(b, MQ3pin);
    
    % Update the voltage data
    voltageData(i) = voltage;
    timeData(i) = toc(startTime);
    
    % Display the sensor value
    % fprintf('Sensor Value: %.2f', voltage);
    % fprintf('\n');
    
    % Update the plot
    set(h, 'XData', timeData(1:i), 'YData', voltageData(1:i));
    drawnow;
    
    % Wait a short time before the next reading
    %pause(0.01); % Adjust the pause duration as needed
end

% Define the models as anonymous functions
M1 = @(a, b, c, d, t) (a ./ sqrt(t)) .* exp(-b * ((d - c*t).^2) ./ t);
M2 = @(a, b, c, d, t) (a ./ t.^(3/2)) .* exp(-b * ((c*t - d).^2) ./ t);

% Ensure timeData and voltageData are column vectors
timeData = timeData(:);
voltageData = voltageData(:);

% Define the fit options with starting points and bounds
opts = fitoptions('Method', 'NonlinearLeastSquares', ...
                  'StartPoint', [1, 1, 1], ...
                  'Lower', [-Inf, -Inf, -Inf], ...
                  'Upper', [Inf, Inf, Inf]);

% Define the fit types using 'fittype' and the fit options
ft1 = fittype('a / sqrt(t) * exp(-b * (d - c*t)^2 / t)', 'independent', 't', ...
              'coefficients', {'a', 'b', 'c'}, 'options', opts);
ft2 = fittype('a / t^(3/2) * exp(-b * (c*t - d)^2 / t)', 'independent', 't', ...
              'coefficients', {'a', 'b', 'c'}, 'options', opts);


% Fit the models to the subset of the data
[fitResult1, gof1] = fit(timeData, voltageData, ft1);
[fitResult2, gof2] = fit(timeData, voltageData, ft2);

% Display the fit coefficients
coefficients1 = coeffvalues(fitResult1);
coefficients2 = coeffvalues(fitResult2);
disp('Fit Coefficients for Model 1:');
disp(coefficients1);
disp('Fit Coefficients for Model 2:');
disp(coefficients2);

% Plot the averaged data, the subset used for fitting, and the fitted curves
figure;
hold on;
plot(timeData, voltageData, 'b.'); % Data
plot(fitResult1, 'r-'); % Fit for Model 1
plot(fitResult2, 'g-'); % Fit for Model 2
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Averaged Sensor Voltage vs. Time with Model Fits');
legend('Data', 'Model 1 Fit', 'Model 2 Fit');
hold off;