%% qoeGreedyCaching.m
% Simulate QoE driven greedy caching.
% @Params: vidID ---- IDs for all videos. 
%          DN ---- the user demand distribution.
%          Q ---- the true value of QoE matrix in VoD system
%          observed_Q ---- the observed QoE matrix from cache agents
%          optQoE ---- the maximum QoE gain from optimal solution.
%          requests ---- requests of content to be sent in simulation.
%          splIntvl ---- the number of requests to skip during sample of
%                        results.
%          M ---- the number of cache agents in the system.
%          B ---- the number of videos to be cached in each node.
% @return savingDynamics ---- the simulation dynamics of cost saving and
%                       cost saving percentage compared to optimal
%                       solution.
% node.

function [qoeGainPercent, qoeGainDynamics, requestQMat, cacheMat, sQ] = qoeGreedyCaching(initTyp, isTracking, DN, Q, sQ, sigma_Q, optQoE, rootQ, requests, splIntvl, M, B, givenMat)
    %% Generate User Requests and Iterate the agent local greedy caching algorithm.
    qoeGainDynamics = [];
    qoeGainPercent = [];
    vidID = (1 : length(DN))';
    requestQMat = zeros(length(requests), 1);
    
    if strcmp(initTyp, 'non')
        cacheMat = reshape(vidID(1:M*B), M, B);
    elseif strcmp(initTyp, 'full')
        cacheMat = repmat(vidID(1 : B)', M, 1);
    elseif strcmp(initTyp, 'given')
        cacheMat = givenMat;
    else
        cacheMat = randi(length(DN), M, B);
    end
    
    if strcmp(isTracking, 'non')
        sQ = Q;
    end
    
    % Compute current QoE gain.
    curQoEGain = computeQoEGain(cacheMat, DN, Q);
    qoeGainDynamics = [qoeGainDynamics; curQoEGain];
    curQoEPercent = curQoEGain ./ optQoE;
    qoeGainPercent = [qoeGainPercent; curQoEPercent];

    %% Iterate through all requests to update content placement.
    for i = 1 : length(requests)
        node = randi([1, M]);
        curRequest = requests(i);
        nodeCache = cacheMat(node, :);
        nodeQ = sQ(node, :);
        stream_agent = node;
        cachedItemUtil = getQoEUtil(cacheMat, DN, node, sQ);
        if ~sum(nodeCache == curRequest)
            isCached = sum(cacheMat(:) == curRequest);

            if isCached
                [cachedAgents, ~] = find(cacheMat == curRequest);
                [Q_peer_max, Q_peer_max_agent] = max(nodeQ(cachedAgents));
                stream_agent = cachedAgents(Q_peer_max_agent);
                Q_leaf = nodeQ(node);
                curUtil = DN(curRequest) .* (Q_leaf - Q_peer_max);
            else
                stream_agent = 0;
                curUtil = DN(curRequest) .* sum(nodeQ);
            end

            [sortVal, sortVidID] = sort(cachedItemUtil);

            if curUtil > sortVal(1)
                nodeCache(sortVidID(1)) = curRequest;
                cacheMat(node, :) = nodeCache;
            end
        end
        
        % Update the observed QoE
        if stream_agent > 0
            requestQ = max(min(5, normrnd(Q(node, stream_agent), sigma_Q)), 0);
        else
            requestQ = max(min(5, normrnd(rootQ, sigma_Q)), 0);
        end
        
        if strcmp(isTracking, 'track') && (stream_agent > 0)
            alpha = 0.5;
            sQ(node, stream_agent) = alpha * sQ(node, stream_agent) + (1 - alpha) * requestQ;
        end
        
        requestQMat(i) = requestQ;
        
        if rem(i, splIntvl) == 0
            % Compute current QoE gain.
            curQoEGain = computeQoEGain(cacheMat, DN, Q);
            qoeGainDynamics = [qoeGainDynamics; curQoEGain];
            curQoEPercent = curQoEGain ./ optQoE;
            qoeGainPercent = [qoeGainPercent; curQoEPercent];
        end
    end
end