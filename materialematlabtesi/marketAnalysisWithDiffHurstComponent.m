clc; close all; clearvars;

%% Load data from 'prezzi.mat' file into the workspace
load DatiFinal.mat                 

Valori = P_Asia';

% Calculate log returns for the financial data
Ret = diff(log(Valori));
Ret = Ret(:, 1:end);

% Define Ret dimensions
[numRows, numCols] = size(Ret);

% Set parameters for window sizes
InS = 7 * 10; % Input window size
OutS = 7;     % Output window size

%% Containers for storing results
StratOnlyRet = [];
StratOnlyHRS = [];
StratDouble = [];

%% Thresholds for decision making
Htreup = 0.7;    % Threshold for HRS (Hurst) to determine upward trend
Htredown = 0.3;  % Threshold for HRS (Hurst) to determine downward trend
RetPval = 0.2;   % Threshold for p-value in linear regression
RetBeta = 0;     % Threshold for beta value in linear regression

% Create a figure for the plot
figure;
plotHandle = plot(0, 0, 'b-', 0, 0, 'r--');
title('Cumulative Returns Over Iterations');
xlabel('Iteration');
ylabel('Cumulative Return');
legend('Double Sorting', 'Single Sorting', 'Location', 'best');
grid on;

% Add a horizontal line at y = 0
% Initialize a horizontal line
zeroLine = line([0, 1], [0, 0], 'Color', 'black', 'LineStyle', '--');

% Initialize arrays for storing cumulative returns
CumulativeDouble = zeros(1, numel(InS:OutS:size(Ret)));
CumulativeSingle = zeros(1, numel(InS:OutS:size(Ret)));
count = 1; % Counter for iterations

%% Main loop iterating over the financial data
for t = InS:OutS:size(Ret)
    % Check
    % try
    % Select input and output data for analysis window
    DatiIn = Ret(t - InS + 1:t, :);
    DatiOut = Ret(t + 1:t + OutS, :);

    % Initialize arrays for HRS, beta, and p-value
    RetIn_beta = zeros(size(DatiIn, 2), 1);
    RetIn_pval = zeros(size(DatiIn, 2), 1);
    HRS = zeros(size(DatiIn, 2), 1);

    % Loop through columns for each financial data series
    for j = 1:numCols

        %HRS(j) = RS(DatiIn(:, j), 0);  % R/S method
        %HRS(j) = absval(DatiIn(:, j)); % Absolute moment method
        %HRS(j) = aggvar(DatiIn(:, j)); $ Aggregate Variance method
        %HRS(j) = per(DatiIn(:, j)); $ Peridogram Method
        
        %% STRATEGY : Here, we have to use different strategies with different data.
        %% some time daywise and sometime hourwise and see how is this performing
        %% when we calculate different variants of the Hurst exponent and
        %% use them to plot on the graph and see the results.
        %% Call fast_NVG function to create the visibility graph
        visibilityGraph = fast_NVG(DatiIn(:, j),1:length(DatiIn(:, j)),'u',0);
            
        %% Calculate the degree of each node in the visibility graph
        degree = sum(visibilityGraph);

        %% Convert degree to a non-sparse numeric array
        degree = full(degree);

        %% Calculate the unique degrees and their counts (degree distribution)
        unique_degrees = unique(degree);
        degree_counts = histc(degree, unique_degrees);
        
        %% Remove zero-degree nodes as log(0) is undefined
        nonzero_degrees = unique_degrees(degree_counts > 0);
        nonzero_counts = degree_counts(degree_counts > 0);

        %% Fit a linear model to the logarithm of degree distribution
        log_degrees = log(nonzero_degrees);
        log_counts = log(nonzero_counts);

        %% Fit a linear model (y = mx + c)
        % Note: There could be some warnings when the size is very small.
        coefficients = polyfit(log_degrees, log_counts, 1);
        alpha = -coefficients(1); % The negative of the slope corresponds to alpha
        
        % This corresponds to the new strategy.
        HRS(j) = (3 - alpha)/2;
        
        
        % Perform linear regression to get beta (slope) and p-value
        mdl = fitlm(1:size(DatiIn, 1), DatiIn(:, j));
        RetIn_beta(j) = table2array(mdl.Coefficients(2, 1)); % Get slope (beta)
        RetIn_pval(j) = table2array(mdl.Coefficients(2, 4)); % Get p-value
    end

    % Evaluate HRS to categorize trends (positive/negative LTM)
    SelezionoH = zeros(size(DatiIn, 2), 1);
    SelezionoH(HRS >= Htreup) = 1;  % Positive Long-Term Memory (LTM)
    SelezionoH(HRS <= Htreup) = 2;  % Negative Long-Term Memory (LTM)

    % Evaluate beta and p-value to categorize returns (positive/negative)
    SelezionoR = zeros(size(DatiIn, 2), 1);
    SelezionoR(RetIn_beta > RetBeta & RetIn_pval <= RetPval) = 1; % Positive return
    SelezionoR(RetIn_beta < RetBeta & RetIn_pval <= RetPval) = 2; % Negative return

    % Identify the intersection of HRS and return categorizations
    SelezionoTot = zeros(size(DatiIn, 2), 1);
    SelezionoTot(SelezionoR == 1 & SelezionoH == 1) = 1; % Positive return and LTM positive
    SelezionoTot(SelezionoR == 2 & SelezionoH == 2) = 2; % Negative return and LTM negative
    SelezionoTot(SelezionoR == 2 & SelezionoH == 1) = 3; % Negative return and LTM positive
    SelezionoTot(SelezionoR == 1 & SelezionoH == 2) = 4; % Positive return and LTM negative

    % Calculate returns based on different categorizations
    RetOuts1 = mean(sum(DatiOut(:, SelezionoTot == 1), 1)); % Double sorting result
    RetOuts2 = mean(sum(DatiOut(:, SelezionoTot == 2), 1)); % Double sorting result
    RetOuts3 = mean(sum(-DatiOut(:, SelezionoTot == 3), 1)); % Double sorting result
    RetOuts4 = mean(sum(-DatiOut(:, SelezionoTot == 4), 1)); % Double sorting result

    RetDouble(1) = RetOuts1;
    RetDouble(2) = RetOuts2;
    RetDouble(3) = RetOuts3;
    RetDouble(4) = RetOuts4;

    RetOuts1R = mean(sum(DatiOut(:, SelezionoR == 1), 1)); % Single sorting result
    RetOuts2R = mean(sum(-DatiOut(:, SelezionoR == 2), 1)); % Single sorting result

    RetSingleR(1) = RetOuts1R;
    RetSingleR(2) = RetOuts2R;

    %% Double Sorting Cumulative Returns
    % This value represents the cumulative return generated by the strategy 
    %   that involves categorizing and sorting the data based on both 
    %   Hurst exponent (HRS) and return characteristics.
    % It accumulates the returns obtained from different combinations of 
    %   positive and negative return and trend categories.
    % The higher the cumulative return, the more profitable the strategy 
    %   has been over the considered time frames. A positive value suggests 
    %   a profitable strategy, whereas a negative value indicates losses.

    %% Single Sorting Cumulative Returns
    % This value represents the cumulative return obtained by a strategy 
    %   that involves sorting the data based only on return characteristics,
    %   disregarding the trend analysis (Hurst exponent).
    % It accumulates returns based on positive and negative return 
    %   categories irrespective of the trend analysis.
    % Comparing this cumulative return with the double sorting cumulative 
    %   return helps in evaluating the contribution of incorporating 
    %   trend analysis (Hurst exponent) into the strategy. A higher 
    %   value might suggest the additional value provided by 
    %   considering both trends and returns
    
    % Store results in respective arrays for analysis
    StratDouble = [StratDouble; RetDouble];
    StratOnlyRet = [StratOnlyRet; RetSingleR];

     % Calculate cumulative returns during each iteration
    CumulativeDouble(count) = nansum(nansum(StratDouble, 2));
    CumulativeSingle(count) = nansum(nansum(StratOnlyRet, 2));

    % Update the plot with new cumulative returns
    set(plotHandle(1), 'XData', 1:count, 'YData', CumulativeDouble(1:count));
    set(plotHandle(2), 'XData', 1:count, 'YData', CumulativeSingle(1:count));
    
    % Update zeroLine position (horizontal line at y = 0)
    set(zeroLine, 'XData', [0, count], 'YData', [0, 0]);
    
    % Update plot title with the current iteration
    title(['Cumulative Returns Over Iterations (Iteration ', num2str(count), ')']);
    
    % Force the plot to update
    drawnow;
    
    % Increment the iteration count
    count = count + 1;

    % Display cumulative returns during each iteration
    disp(['Double Sorting CumRet: ', num2str(nansum(nansum(StratDouble, 2))), ...
        ' - Single Sorting Ret CumRet: ', num2str(nansum(nansum(StratOnlyRet, 2)))]);

    % catch
    %     % Handle potential errors in the loop
    % end
end
clc; close all; clearvars;