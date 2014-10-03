%% Global Optimal algorithms described in paper:
% [1] Borst, Sem, Varun Gupta, and Anwar Walid. "Distributed caching 
% algorithms for content distribution networks." INFOCOM, 2010 Proceedings 
% IEEE. IEEE, 2010.
% [2] Borst, Sem, Varun Gupta, and Anwar Walid. "Self-organizing algorithms 
% for cache cooperation in content distribution networks." Bell Labs 
% Technical Journal14.3 (2009): 113-125.

% clc;
% clear all;
% close all;
% 
% %% System configuration
% % The bandwidth cost to get a content from root server. Content size is 20 MB and the number of links to go through is 5.
% cr = 2;
% cp = 1;
% M = 50;
% N = 10000;
% B = 100;
% 
% c_leaf = M*cr - (M-1)*cp;
% c_peer = (M-1)*cp;
% 
% %% Generate User Demand Distribution
% q = 10;
% alpha = 0.8;
% PN = (q + (1:N)).^(-alpha);
% DN = PN ./ sum(PN);

function cost_saving = optCost(DN, c_leaf, c_peer, N, M, B)

%% Compute optimal soluction
% Optimization input for intlinprog.
intcon = 2*N;
f = [-DN' .* c_leaf; 
     -DN' .* c_peer];
A1 = [ones(1, N) (M - 1).*ones(1, N)];
AN = diag(ones(2*N, 1), 0);
A = [A1;
     AN;
     -AN];

b = [M*B;
     ones(2*N,1);
     zeros(2*N, 1)];
 
% Solve the problem.
[x, fval, ~, ~] = intlinprog(f, intcon, A, b);

cost_saving = -fval;

disp(['The optimal solution can save bandwidth :' num2str(cost_saving) 'MB']);


end
