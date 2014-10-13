%% Local Greedy Algorithms for QoE Maximization in a VoD system with 
% non-stationary QoE matrix
% Details can be found in Slides in http://1drv.ms/1EMCECm
% qoeLocalGreedyNonStationary.m
clc;
close all;
clear all;

plotLines = {'-b', ':+g', '--dr', '-og', '-.k', '-*y', '-.ob', '-+r', '-sb', '-dg'};

%% System configuration (Should be the same as optCost)
M = 10;
N = 1000;
B = 100;
% The QoE Gain to get a content from local server.
q1 = 4;
q2 = 4.5;
% The QoE Gain to get a content from peer server.
qp1 = 3;
qp2 = 1.5;
% The QoE to get a content from root node.
rootQ = 0.5;

% QoE Matrix True Value
Q1 = ones(M, M) .* qp1;
Q1(1 : M + 1 : M*M) = q1;
Q2 = ones(M, M) .* qp2;
Q2(1 : M + 1 : M*M) = q2;
observed_Q = ones(M, M) .* 2.5;

%% The Q parameters before change.
% The utility to cache a content in an agent while others do not have it.
u_leaf_1 = q1 + (M - 1)*qp1;
coef_leaf_1 = q1 + (M - 1)*qp1;
% The utility to cache a content in an agent while some other do have it.
u_peer_1 = q1 - qp1;
coef_peer_1 = (M - 1) * (q1 - qp1);

%% The Q parameters after change.
% The utility to cache a content in an agent while others do not have it.
u_leaf_2 = q2 + (M - 1)*qp2;
coef_leaf_2 = q2 + (M - 1)*qp2;
% The utility to cache a content in an agent while some other do have it.
u_peer_2 = q2 - qp2;
coef_peer_2 = (M - 1) * (q2 - qp2);

%% Generate User Demand Distribution
p = 10;
alpha = 0.8;
PN = (p + (1:N)).^(-alpha);
% DN = PN .* v;
DN = PN ./ sum(PN);
vidID = (1 : length(DN))';

% Generate Simulation Requests.
numRequests = 20000;
requests = datasample(vidID, numRequests, 'Weights', DN);

% Compute the real demand weights.
DCount = hist(requests, vidID);
DN_Real = DCount ./ numRequests;

%% Optimal Bandwidth Cost Saving
% Optimal Saving
optQoE1 = optQoE(DN_Real, coef_leaf_1, coef_peer_1, N, M, B);
% Optimal Saving
optQoE2 = optQoE(DN_Real, coef_leaf_2, coef_peer_2, N, M, B);
% optSaving = 10.7591;

%% Simulation of local greedy algorithm.
partRequests = 10000;
splIntvl = 100;
sigma_Q = 0.5;
[qoeGainPercent1, ~, ~, cacheMat, sQ] = qoeGreedyCaching('full', 'track', DN_Real, Q1, observed_Q, sigma_Q, optQoE1, rootQ, requests(1 : partRequests), splIntvl, M, B);
[qoeGainPercent2, ~, ~, ~, ~] = qoeGreedyCaching('given', 'track', DN_Real, Q2, sQ, sigma_Q, optQoE2, rootQ, requests(partRequests + 1 : end), splIntvl, M, B, cacheMat);

qoeGainPercent = [qoeGainPercent1; qoeGainPercent2];

figure(1), hold on;
title('Performance Ration in VoD system with non-stationary QoE matrix', 'FontSize',14);
axis([0 numRequests./M 0.6 1.1]);
plot((0 : splIntvl : (length(qoeGainPercent) - 1)*splIntvl)./M, qoeGainPercent, plotLines{1}, 'LineWidth', 4);
xlabel('Requests per agent', 'FontSize',14);
ylabel('Performance ratio to optimal solution','FontSize',14);
% AX = legend('Accurate QoE Matrix', 'Tracking QoE with sigma 0.5', 'Tracking QoE with sigma 1');
% LEG = findobj(AX,'type','text');
% set(LEG,'FontSize',14)
hold off;