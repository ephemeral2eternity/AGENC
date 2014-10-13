%% Given a cache placement matrix and requests
% Compute the QoE of all requests.
% getQoE.m

function requestQoE = getQoE(requests, cacheMat, Q, sigma_Q, rootQ)
    M = size(cacheMat, 1);
    requestQoE = zeros(length(requests), 1);
    %% Iterate through all requests to update content placement.
    for i = 1 : length(requests)
        node = randi([1, M]);
        curRequest = requests(i);
        nodeCache = cacheMat(node, :);
        nodeQ = Q(node, :);
        
        if ~sum(nodeCache == curRequest)
            isCached = sum(cacheMat(:) == curRequest);
            
            if isCached
                [cachedAgents, ~] = find(cacheMat == curRequest);
                [~, Q_peer_max_agent] = max(nodeQ(cachedAgents));
                stream_agent = cachedAgents(Q_peer_max_agent);
                requestQoE(i) = max(min(5, normrnd(Q(node, stream_agent), sigma_Q)), 0);
            else
                requestQoE(i) = max(min(5, normrnd(rootQ, sigma_Q)), 0);
            end
        else
           stream_agent = node;
           requestQoE(i) = max(min(5, normrnd(Q(node, stream_agent), sigma_Q)), 0);
        end
    end

end