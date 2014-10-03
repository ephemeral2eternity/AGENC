%% computeBWSaving.m
% Compute Bandwidth Cost Saving using a caching matrix.
% @Params: cacheMat ---- caching matrix. Each row represents a list of
% content cached in col's node.
%         c_leaf ---- the cost saving to cache a content in current node in 
%                     case any other node does not have the content.
%         c_peer ---- the cost saving to cache a content in current node in
%                     case peer node has cached the content.
% @return bwSaving ---- the total saving of bandwidth for current
%                           caching scheme.

function bwSaving = computeBWSaving(cacheMat, DN, c_leaf, c_peer)
    cacheArray = cacheMat(:);
    itemAppears = unique(cacheArray);
    itemCounts = hist(cacheArray, itemAppears) - 1;
    p_n = zeros(length(DN), 1);
    q_n = p_n;
    p_n(itemAppears) = 1;
    q_n(itemAppears) = itemCounts ./ (size(cacheMat, 1) - 1);
    
    bwSaving = sum (DN' .* (c_leaf .* p_n + c_peer .* q_n));
end