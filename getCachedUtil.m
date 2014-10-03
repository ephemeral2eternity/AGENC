%% getCacheUtil.m
% Compute Cache Utility for a node.
% @Params: cacheMat ---- caching matrix. Each row represents a list of
% content cached in col's node.
%         DN ---- the user demand distribution.
%         node ---- the node ID to compute cache utility.
% @return cachedItemUtil ---- the utility of each cached item in current
% node.

function cachedItemUtil = getCachedUtil(cacheMat, DN, node, c_leaf, c_peer)
    cachedItem = cacheMat(node, :);
    M = size(cacheMat, 1);
    peerCacheMat = cacheMat;
    peerCacheMat(node, :) = [];
    
    tmpPeerCacheMat = repmat(peerCacheMat(:), 1, length(cachedItem));
    tmpCachedItemMat = repmat(cachedItem, length(peerCacheMat(:)), 1);
    isPeerCached = (sum((tmpPeerCacheMat == tmpCachedItemMat), 1) > 0);

    cachedItemUtil = isPeerCached .* DN(cachedItem) .* c_peer ./ (M - 1) ...
            + DN(cachedItem) .* c_leaf .* (1 - isPeerCached);
end
