% Define the threshold value
Threshold = 1.5;

% Number of readings per round
numReadings = 220;
numRounds = 6;

% Create an Arduino object
b = arduino('COM3', 'Uno'); % Change 'COM3' to your Arduino's serial port

% MQ3 pin
MQ3pin = 'A0';

disp('MQ3 warming up!');
pause(2); % Allow the MQ3 to warm up for 2 seconds

% Initialize variables for storing data
allVoltageData = zeros(numRounds, numReadings);
allTimeData = zeros(numRounds, numReadings);

% Set up the plot for real-time data
figure;
h = plot(zeros(1, numReadings), zeros(1, numReadings));
ylim([0 5]); % Assuming the voltage range is 0 to 5V
xlim([0 20]); % Adjust x-axis limit based on expected time duration
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Real-Time Sensor Voltage Measurement');

for round = 1:numRounds
    fprintf('Starting round %d...\n', round);
    pause(1)

    startTime = tic;

    for i = 1:numReadings
        % Read the sensor value from analog pin A0
        voltage = readVoltage(a, MQ3pin);

        % Update the voltage data
        allVoltageData(round, i) = voltage;
        allTimeData(round, i) = toc(startTime);

        % Display the sensor value
        fprintf('Round %d - Sensor Value: %.2f', round, voltage);

        if voltage > Threshold
            fprintf(' | detected!');
        end

        fprintf('\n');

        % Update the real-time plot
        set(h, 'XData', allTimeData(round, 1:i), 'YData', allVoltageData(round, 1:i));
        drawnow;

        % Wait a short time before the next reading
        pause(0.05); % Adjust the pause duration as needed
    end
end

% Ensure timeData and voltageData are column vectors
avgTimeData = avgTimeData(:);
avgVoltageData = avgVoltageData(:);

% Define the models as anonymous functions
M1 = @(a, b, c, d, t) (a ./ sqrt(t)) .* exp(-b * ((d - c*t).^2) ./ t);
M2 = @(a, b, c, d, t) (a ./ t.^(3/2)) .* exp(-b * ((c*t - d).^2) ./ t);

% Define the fit options with starting points and bounds
opts = fitoptions('Method', 'NonlinearLeastSquares', ...
                  'StartPoint', [1, 1, 1, 1], ...
                  'Lower', [0, 0, 0, 0], ...
                  'Upper', [Inf, Inf, Inf, Inf]);

% Define the fit types using 'fittype' and the fit options
ft1 = fittype('a / sqrt(t) * exp(-b * (d - c*t)^2 / t)', 'independent', 't', ...
              'coefficients', {'a', 'b', 'c', 'd'}, 'options', opts);
ft2 = fittype('a / t^(3/2) * exp(-b * (c*t - d)^2 / t)', 'independent', 't', ...
              'coefficients', {'a', 'b', 'c', 'd'}, 'options', opts);

% Fit the models to the subset of the data
[fitResult1, gof1] = fit(fitTimeData, fitVoltageData, ft1);
[fitResult2, gof2] = fit(fitTimeData, fitVoltageData, ft2);

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
plot(avgTimeData, avgVoltageData, 'b.', 'MarkerSize', 10); % Averaged data
plot(fitTimeData, fitVoltageData, 'ko', 'MarkerSize', 5); % Subset data used for fitting
plot(fitResult1, 'r-'); % Fit for Model 1
plot(fitResult2, 'g-'); % Fit for Model 2
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Averaged Sensor Voltage vs. Time with Model Fits');
legend('Averaged Data', 'Subset Data for Fit', 'Model 1 Fit', 'Model 2 Fit');
hold off;

% Export data for each round
for round = 1:numRounds
    roundDataToExport = table(allTimeData(round, :)', allVoltageData(round, :)', ...
                              'VariableNames', {'Time', 'Voltage'});
    
    % Write the table to a sheet in an Excel file
    writetable(roundDataToExport, 'round_data.xlsx', 'Sheet', sprintf('Round %d', round));
end

% Combine the averaged data into a table for easier export
dataToExport = table(avgTimeData, avgVoltageData, 'VariableNames', {'Time', 'Voltage'});

% Write the averaged data to an Excel file
writetable(dataToExport, 'averaged_data.xlsx', 'Sheet', 'Averaged Data');

% Combine the subset of data used for fitting into a table
fitDataToExport = table(fitTimeData, fitVoltageData, 'VariableNames', {'Time', 'Voltage'});

% Write the subset of data used for fitting to a sheet in the same Excel file
writetable(fitDataToExport, 'fit_data.xlsx', 'Sheet', 'Fit Data');
