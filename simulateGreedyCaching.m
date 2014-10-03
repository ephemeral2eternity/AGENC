%% simulateGreedyCaching.m
% Compute Cache Utility for a node.
% @Params: vidID ---- IDs for all videos. 
%          DN ---- the user demand distribution.
%          c_leaf ---- the cost saving to cache a content in current node in 
%                      case any other node does not have the content.
%          c_peer ---- the cost saving to cache a content in current node in
%                      case peer node has cached the content.
%          optSaving ---- the optimal cost saving for the global optimal
%                      solution.
%          requests ---- requests of content to be sent in simulation.
%          splIntvl ---- the number of requests to skip during sample of
%                        results.
%          M ---- the number of nodes in the system.
%          B ---- the number of videos to be cached in each node.
% @return savingDynamics ---- the simulation dynamics of cost saving and
%                       cost saving percentage compared to optimal
%                       solution.
% node.

function [savingPercent, savingVal] = simulateGreedyCaching(initTyp, DN, c_leaf, c_peer, optSaving, requests, splIntvl, M, B)
    %% Generate User Requests and Iterate the agent local greedy caching algorithm.
    savingPercent = [];
    savingVal = [];
    vidID = (1 : length(DN))';
    
    if strcmp(initTyp, 'non')
        cacheMat = reshape(vidID(1:M*B), M, B);
    elseif strcmp(initTyp, 'full')
        cacheMat = repmat(vidID(1 : B)', M, 1);
    else
        cacheMat = randi(length(DN), M, B);
    end
    
    % Compute current saving.
    curSaving = computeBWSaving(cacheMat, DN, c_leaf, c_peer);
    savingVal = [savingVal; curSaving];
    curSavingPercent = curSaving ./ optSaving;
    savingPercent = [savingPercent; curSavingPercent];

    %% Iterate through all requests to update content placement.
    for i = 1 : length(requests)
        node = randi([1, M]);
        curRequest = requests(i);
        nodeCache = cacheMat(node, :);
        cachedItemUtil = getCachedUtil(cacheMat, DN, node, c_leaf, c_peer);
        if ~sum(nodeCache == curRequest)
            isCached = sum(cacheMat(:) == curRequest);

            if isCached
                curUtil = DN(curRequest) .* c_peer;
            else
                curUtil = DN(curRequest) .* c_leaf;
            end

            [sortVal, sortVidID] = sort(cachedItemUtil);

            if curUtil > sortVal(1)
                nodeCache(sortVidID(1)) = curRequest;
                cacheMat(node, :) = nodeCache;
            end
        
        end
        if rem(i, splIntvl) == 0
            curSaving = computeBWSaving(cacheMat, DN, c_leaf, c_peer);
            savingVal = [savingVal; curSaving];
            curSavingPercent = curSaving ./ optSaving;
            savingPercent = [savingPercent; curSavingPercent];
        end
    end
end