%% Global Optimal algorithms described in paper:
% [1] Borst, Sem, Varun Gupta, and Anwar Walid. "Distributed caching 
% algorithms for content distribution networks." INFOCOM, 2010 Proceedings 
% IEEE. IEEE, 2010.
% [2] Borst, Sem, Varun Gupta, and Anwar Walid. "Self-organizing algorithms 
% for cache cooperation in content distribution networks." Bell Labs 
% Technical Journal14.3 (2009): 113-125.

clc;
clear all;
close all;

%% System configuration
% The bandwidth cost to get a content from root server. Content size is 20 MB and the number of links to go through is 5.
cr = 100;
cp = 40;
M = 20;
N = 1000;

c_leaf = M*cr - (M-1)*cp;
c_peer = (M-1)*cp;

%% Compute optimal soluction
q = 10;
alpha = 0.8;
PN = (q + (1:N)).^(-alpha);
r = 1000;
DN = PN .* r;

% Optimization input for intlinprog.
intcon = 2*N;
f = [- DN' .* c_leaf; 
     - DN' .* c_peer];
A1 = [ones(1, N) (M - 1).*ones(1, N)];
AN = diag(ones(2*N, 1), 0);
A = [A1;
     AN];
b = [100;
     ones(2*N,1)];
 
% Solve the problem.
[x, fval, ~, ~] = intlinprog(f, intcon, A, b);



