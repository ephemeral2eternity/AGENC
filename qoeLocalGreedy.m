%% Local Greedy Algorithms for QoE Maximization:
% Details can be found in Slides in http://1drv.ms/1EMCECm
% qoeLocalGreedy.m
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
% The QoE to get a content from root node.
rootQ = 1;

% QoE Matrix True Value
Q = ones(M, M) .* qp;
Q(1 : M + 1 : M*M) = q;
observed_Q = ones(M, M) .* qp;

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

%% Optimal Bandwidth Cost Saving
% Optimal Saving
optQoE = optQoE(DN_Real, coef_leaf, coef_peer, N, M, B);
% optSaving = 10.7591;

%% Simulation of local greedy algorithm.
numRequests = 10000;
splIntvl = 100;
sigma_Q = 0.5;
[qoeGainPercent1, qoeGainDynamics1] = qoeGreedyCaching('full', 'non', DN_Real, Q, observed_Q, sigma_Q, optQoE, rootQ, requests, splIntvl, M, B);
[qoeGainPercent2, qoeGainDynamics2] = qoeGreedyCaching('full', 'track', DN_Real, Q, observed_Q, sigma_Q, optQoE, rootQ, requests, splIntvl, M, B);
sigma_Q = 1;
[qoeGainPercent3, qoeGainDynamics3] = qoeGreedyCaching('full', 'track', DN_Real, Q, observed_Q, sigma_Q, optQoE, rootQ, requests, splIntvl, M, B);

figure(1), hold on;
axis([0 numRequests./M 0.6 1.1]);
plot((0 : splIntvl : numRequests)./M, qoeGainPercent1, plotLines{1});
plot((0 : splIntvl : numRequests)./M, qoeGainPercent2, plotLines{2});
plot((0 : splIntvl : numRequests)./M, qoeGainPercent3, plotLines{3});
xlabel('Requests per agent', 'FontSize',14);
ylabel('Performance ratio to optimal solution','FontSize',14);
AX = legend('Accurate QoE Matrix', 'Tracking QoE with sigma 0.5', 'Tracking QoE with sigma 1');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',14)
hold off;