%% getQoEUtil.m
% Compute cached items' qoe gain utility for a node.
% @Params: cacheMat ---- caching matrix. Each row represents a list of
% content cached in row's node.
%         DN ---- the user demand distribution.
%         node ---- the node ID to compute cache utility.
% @return cachedItemUtil ---- the utility of each cached item in current
% node.

function cachedItemQoEUtil = getQoEUtil(cacheMat, DN, node, Q)
    cachedItem = cacheMat(node, :);
    cachedItemQoEUtil = zeros(length(cachedItem), 1);
    Q_node = Q(node, :);
    
    for i = 1 : length(cachedItem)
        cur_item = cachedItem(i);
        [cached_agent, ~] = find(cacheMat == cur_item);
        cached_agent(cached_agent == node) = [];
        leafQ = Q_node(node);
        if ~isempty(cached_agent)
            peerQ = max(Q_node(cached_agent));
            obtained_Q = DN(cur_item) .* (leafQ - peerQ);
        else
            obtained_Q = DN(cur_item) .* sum(Q_node);
        end
            
        cachedItemQoEUtil(i) = obtained_Q;
    end
end
