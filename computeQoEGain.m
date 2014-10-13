%% computeQoEGain.m
% Compute QoE Gain using a caching matrix and a QoE matrix.
% @Params: cacheMat ---- caching matrix. Each row represents a list of
% content cached in row's node.
%         Q ---- the true values of QoE matrix
% @return QoEGain ---- the total QoE gain of current caching solution.

function qoeGain = computeQoEGain(cacheMat, DN, Q)
    M = size(cacheMat, 1);
    vidID = 1 : length(DN);
    qoeGain = 0;
    for i = 1 : M
        % Compute QoE gain of local cached items on agent_i.
        node_cache = zeros(length(DN), 1);
        node_cache(cacheMat(i, :)') = 1;
        local_Q = Q(i, i);
        local_Q_gain = local_Q * DN * node_cache;
        
        % Compute QoE gain of peer cached items user demand at current agent.
        peer_Q = Q(i, :);
        peer_Q(i) = 0;
        peer_Q_gain = 0;
        
        % get cached content from all other peers
        peer_cache_mat = cacheMat;
        peer_cache_mat(i, :) = [];
        item_appear_peer = unique(peer_cache_mat(:));
        
        for j = 1 : length(item_appear_peer)
            item = item_appear_peer(j);
            [cached_agent, ~] = find(cacheMat == item);
            if (sum(cached_agent == i) == 0)
                peer_Q_max = max(peer_Q(cached_agent));
                peer_Q_gain = peer_Q_gain + peer_Q_max .* DN(item);
            end
        end
        qoeGain = qoeGain + peer_Q_gain + local_Q_gain;
    end
end