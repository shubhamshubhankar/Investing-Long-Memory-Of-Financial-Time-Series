%% Project work for Financial Data Science
%% Topic: Investing long memory of Financial time series using Hurst exponent found from visibility graph

clc; close all; clearvars;

%% Load data from 'prezzi.mat' file into the workspace
load DatiFinal.mat                 
Valori = P_Asia';
closingPrice = Valori(:, 1);

%% Calculating the daily returns from closing prices.
returns = diff(log(closingPrice));

%% Calculating the hurst exponent using the peridogram method.
%H = per(closingPrice, 1);
%disp(H);

H = RS(closingPrice, 1);  % R/S method
disp(H);
H = absval(closingPrice, 1); % Absolute moment method
disp(H);
H = aggvar(closingPrice, 1); % Aggregate Variance method
disp(H);

%% Creating the adjacency list.
G = cell(length(closingPrice), 1); % Initialize adjacency list (cell array)
t = 1:length(closingPrice); % Create time vector
%t = dates;

%% Call fast_NVG function to create the visibility graph
visibilityGraph = fast_NVG(closingPrice,t,'u',0);

G1 = graph(visibilityGraph);

%% Plot the network graph
figure;
h = plot(G1, 'Layout', 'force'); % Use 'force' layout for better visualization
title('Visibility Graph Network');

%% Calculate the degree of each node in the visibility graph
degree = sum(visibilityGraph);

%% Convert degree to a non-sparse numeric array
degree = full(degree);

%% Calculate the unique degrees and their counts (degree distribution)
unique_degrees = unique(degree);
degree_counts = histc(degree, unique_degrees);

%% Plot the degree distribution
figure;
bar(unique_degrees, degree_counts);
xlabel('Degree');
ylabel('Frequency');
title('Degree Distribution of Visibility Graph');

%% Remove zero-degree nodes as log(0) is undefined
nonzero_degrees = unique_degrees(degree_counts > 0);
nonzero_counts = degree_counts(degree_counts > 0);

%% Fit a linear model to the logarithm of degree distribution
log_degrees = log(nonzero_degrees);
log_counts = log(nonzero_counts);

%% Fit a linear model (y = mx + c)
coefficients = polyfit(log_degrees, log_counts, 1);
alpha = -coefficients(1); % The negative of the slope corresponds to alpha

disp(['Estimated alpha (power-law exponent): ', num2str(alpha)]);

H = (3 - alpha)/2;

disp(['Estimated Hurst exponent: ', num2str(H)]);

% Create fitted line
fitted_line = polyval(coefficients, log_degrees); % Generate y-values for the line

% Plot the original data (log-log plot)
figure;
scatter(log_degrees, log_counts, 'filled'); % Scatter plot of the log-log data
hold on;

% Plot the fitted line
plot(log_degrees, fitted_line, '-r', 'LineWidth', 2); % Red line for the fit

% Add labels, legend, and title
xlabel('log(Degree)');
ylabel('log(Counts)');
title('Log-Log Plot with Linear Fit for Visibility Graph');
legend('Data Points', 'Fitted Line', 'Location', 'Best');

hold off; % End the plotting




