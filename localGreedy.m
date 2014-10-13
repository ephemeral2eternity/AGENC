%% Local Greedy Algorithms described in paper:
% [1] Borst, Sem, Varun Gupta, and Anwar Walid. "Distributed caching 
% algorithms for content distribution networks." INFOCOM, 2010 Proceedings 
% IEEE. IEEE, 2010.
% [2] Borst, Sem, Varun Gupta, and Anwar Walid. "Self-organizing algorithms 
% for cache cooperation in content distribution networks." Bell Labs 
% Technical Journal14.3 (2009): 113-125.

clc;
close all;
clear all;

plotLines = {':+b', '--dr', '-og', '-.k', '-*y', '-.ob', '-+r', '-sb', '-dg'};

%% System configuration (Should be the same as optCost)
% The bandwidth cost to get a content from root server. Content size is 20 MB and the number of links to go through is 5.
cr = 2;
cm = 1;
cp = 1;
M = 10;
N = 10000;
B = 100;

c_leaf = M*(cr + cm) - (M-1)*cp;
c_peer = (M-1)*cp;

%% Generate User Demand Distribution
v = 0.00625;
q = 10;
alpha = 0.8;
PN = (q + (1:N)).^(-alpha);
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
optSaving = optCost(DN_Real, c_leaf, c_peer, N, M, B);
% optSaving = 10.7591;

%% Simulation of local greedy algorithm.
numRequests = 10000;
splIntvl = 100;
[savingPercent1, ~] = simulateGreedyCaching('non', DN_Real, c_leaf, c_peer, optSaving, requests, splIntvl, M, B);
[savingPercent2, ~] = simulateGreedyCaching('full', DN_Real, c_leaf, c_peer, optSaving, requests, splIntvl, M, B);
[savingPercent3, ~] = simulateGreedyCaching('rand', DN_Real, c_leaf, c_peer, optSaving, requests, splIntvl, M, B);

figure(1), hold on;
axis([0 numRequests 0 1]);
plot((0 : splIntvl : numRequests), savingPercent1, plotLines{1});
plot((0 : splIntvl : numRequests), savingPercent2, plotLines{2});
plot((0 : splIntvl : numRequests), savingPercent3, plotLines{3});
AX = legend('Non Replication', 'Full Replication', 'Random');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',14)
hold off;