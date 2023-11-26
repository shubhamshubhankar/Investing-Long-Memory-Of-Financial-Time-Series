%% Project work for Financial Data Science
%% Topic: Investing long memory of Financial time series using Hurst exponent found from visibility graph

%% Downloading the data using Yahoo-Quandl-Market-Data-Downloader
initDate = '1-Jul-2023';
symbol = 'GOOGL';
aaplusd_yahoo_raw = getMarketDataViaYahoo(symbol, initDate);

%% Retrieving the values from the raw data into variables.
dates = datestr(aaplusd_yahoo_raw(:,1).Date);
closingPrice = aaplusd_yahoo_raw.Close;
highPrice = aaplusd_yahoo_raw.High;
lowPrice = aaplusd_yahoo_raw.Low;


%% Creating the timeseries with appropriate parameters.
aaplusd_yahoo = timeseries([closingPrice, highPrice, lowPrice], dates);
aaplusd_yahoo.DataInfo.Units = 'USD';
aaplusd_yahoo.Name = symbol;
aaplusd_yahoo.TimeInfo.Format = "dd-mm-yyyy";

%% Plotting the timeseries curve for the 'GOOGL' stock.
figure('color', 'white'), 
plot(aaplusd_yahoo);
legend({'Close', 'High', 'Low'},'Location', 'northwest');

%% Calculating the daily returns from closing prices.
returns = diff(log(closingPrice));

%% Calculating the hurst exponent using the peridogram method.
H = per(closingPrice, 1);

%% Creating the adjacency list.
G = cell(length(closingPrice), 1); % Initialize adjacency list (cell array)
t = 1:length(closingPrice); % Create time vector

%% Define the left and right indices for the range of data you want to consider
leftIndex = 1;
rightIndex = length(closingPrice);
weight = 2;

%% Assigning the visibility to different nodes.
for i = leftIndex:rightIndex
    visibility = zeros(1, length(closingPrice));

    for j = i+1:rightIndex
        if (i == leftIndex) || (i == rightIndex) || any((closingPrice(j) > max(closingPrice(i+1:j-1))))
            visibility(j) = 1; % Assign visibility based on the condition
        end
    end
    G{i} = find(visibility); % Store visible nodes in the adjacency list
end

%% Call NVG_alg function to create the visibility graph
visibilityGraph = NVG_alg(closingPrice, leftIndex, rightIndex, G, t, weight);

%% Assuming visibilityGraph contains adjacency lists in the first column and weights in the second column
for i = 1:length(visibilityGraph)
    % Check if the second column contains an empty list
    if isempty(visibilityGraph{i, 2})
        % Replace empty list with zeros corresponding to the size of the first column
        visibilityGraph{i, 2} = zeros(size(visibilityGraph{i, 1}));
    end
end

%% Extract adjacency lists and weights from visibilityGraph
adjacencyLists = visibilityGraph(:, 1);
weights = visibilityGraph(:, 2);

%% Create a graph object
G1 = graph();

%% Add nodes to the graph
numNodes = length(adjacencyLists);
G1 = addnode(G1, numNodes);

%% Add edges with weights to the graph
for i = 1:numNodes
    neighbors = adjacencyLists{i};
    edgeWeights = weights{i};
    
    for j = 1:length(neighbors)
        G1 = addedge(G1, i, neighbors(j), edgeWeights(j));
    end
end

%% Plot the network graph
figure;
h = plot(G1, 'Layout', 'force'); % Use 'force' layout for better visualization
title('Visibility Graph Network');
