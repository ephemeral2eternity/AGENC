%% QoE CDF comparison between full replication scheme and QoE driven caching
% scheme.
% compareQoECDF.m
clc;
close all;
clear all;

plotLines = {'-b', ':+g', '--dr', '-og', '-.k', '-*y', '-.ob', '-+r', '-sb', '-dg'};

%% System configuration (Should be the same as optCost)
M = 10;
N = 1000;
B = 100;
% The QoE Gain to get a content from local server.
q = 4;
% The QoE Gain to get a content from peer server.
qp = 2;
% QoE Matrix True Value
Q = ones(M, M) .* qp;
Q(1 : M + 1 : M*M) = q;
observed_Q = ones(M, M) .* qp;

% root node QoE
rootQ = 1;
% The utility to cache a content in an agent while others do not have it.
u_leaf = q + (M - 1)*qp;
coef_leaf = q + (M - 1)*qp;
% The utility to cache a content in an agent while some other do have it.
u_peer = q - qp;
coef_peer = (M - 1) * (q - qp);


%% Generate User Demand Distribution
p = 10;
alpha = 0.8;
PN = (p + (1:N)).^(-alpha);
% DN = PN .* v;
DN = PN ./ sum(PN);
vidID = (1 : length(DN))';

% Generate Simulation Requests.
numRequests = 10000;
requests = datasample(vidID, numRequests, 'Weights', DN);

% Compute the real demand weights.
DCount = hist(requests, vidID);
DN_Real = DCount ./ numRequests;

%% Two caching scheme
popularityCacheMat = repmat(vidID(1 : B)', M, 1);
sigma_Q = 0.5;
requestsQ1 = getQoE(requests, popularityCacheMat, Q, sigma_Q, rootQ);

%% Get local greedy cache mat after 1000 simulation.
%% Optimal Bandwidth Cost Saving
% Optimal Saving
optQoE = optQoE(DN_Real, coef_leaf, coef_peer, N, M, B);

%% Simulation of local greedy algorithm.
numRequests = 10000;
splIntvl = 100;
[~, ~, requestsQ2, greedyCacheMat] = qoeGreedyCaching('full', 'non', DN_Real, Q, observed_Q, sigma_Q, optQoE, rootQ, requests, splIntvl, M, B);
requestsQ3 = getQoE(requests, greedyCacheMat, Q, sigma_Q, rootQ);

figure, hold on;
h1 = cdfplot(requestsQ1);
set(h1, 'LineStyle', '-');
set(h1, 'color', 'k');
set(h1, 'LineWidth',4);
h2 = cdfplot(requestsQ2);
set(h2, 'LineStyle', '--');
set(h2, 'color', 'b');
set(h2, 'LineWidth',4);
h3 = cdfplot(requestsQ3);
set(h3, 'LineStyle', ':');
set(h3, 'color', 'r');
set(h3, 'LineWidth',4);
AX = legend('Cache top popular videos', 'QoE driven Cache Scheme', 'QoE driven cache scheme (converged)');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',14)
hold off;