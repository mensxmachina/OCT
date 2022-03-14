%----------------
%kbiza, 3/4/21, 
%   delete input : dataset 
%----------------

% data: NxM matrix with N samples and M variables
% target: index of target in data
% maxK: maximum conditioning set size
% threshold: significance level alpha
% testFunc: @function(X, Y, Z, data, testParams)
    % X: index of variable X in data
    % Y: index of variable Y in data
    % Z: vector of indices of conditioning variables in data
% testParams: struct containing additional information required for the test

function [selectedVars] = MMPCmod(data, target, maxK, threshold, testFunc, testParams)
nvars = size(data,2);
pvalues = ones(nvars, 1);
stats = zeros(nvars, 1);

remainingVars = true(nvars,1);
remainingVars(target) = false;
selectedVars = [];

% Forward Phase
while any(remainingVars)
    [curvar, curpvalue, remainingVars, pvalues, stats] = findMaxMinAssociation(data, target, maxK, selectedVars, remainingVars, pvalues, stats, testFunc, testParams);
    
    if (curpvalue <= threshold)
        selectedVars = [selectedVars curvar];
        remainingVars(curvar) = false;
    end
    
    remainingVars = remainingVars & pvalues <= threshold;
end

% Backward Phase
[~,idx] = sort(pvalues(selectedVars), 'descend');
toremove = false(length(selectedVars),1);
curSelectedVars = selectedVars(idx);

for i = 1:length(idx)
   curvar = selectedVars(idx(i));
   curSelectedVars = setdiff(curSelectedVars, curvar);
   curpvalue = findMinAssociation(data, target, curvar, maxK, curSelectedVars, pvalues, stats, testFunc, testParams);
   if(curpvalue > threshold)
       toremove(idx(i)) = true;
   else
       curSelectedVars = [curSelectedVars curvar];
   end
end
selectedVars(toremove) = [];

end

function  [bestvar, bestpvalue, remainingVars, pvalues, stats] = findMaxMinAssociation(data, target, maxK, selectedVars, remainingVars, pvalues, stats, testFunc, testParams)

bestvar = [];
bestpvalue = Inf;
beststat = -Inf;

for var = 1:length(remainingVars)
    if(remainingVars(var))
        [curpvalue, curstat, pvalues, stats] = findMinAssociation(data, target, var, maxK, selectedVars, pvalues, stats, testFunc, testParams);
        if(curpvalue < bestpvalue || (curpvalue == bestpvalue && curstat > beststat))
            bestvar = var;
            bestpvalue = curpvalue;
            beststat = curstat;
        end
    end
end

end

function [maxpvalue, minstat, pvalues, stats] = findMinAssociation(data, target, var, maxK, selectedVars, pvalues, stats, testFunc, testParams)

maxpvalue = pvalues(var);
minstat = stats(var);
    
maxK = min([maxK length(selectedVars)]);

if(maxK == 0)
    [pvalue, stat] = testFunc(target, var, [], data, testParams);
              
    maxpvalue = pvalue;
    pvalues(var) = pvalue;
    minstat = stat;
    stats(var) = stat;
else
    % Case k = 1
    [pvalue, stat] = testFunc(target, var, selectedVars(end), data, testParams);
    
    
    if(pvalue > maxpvalue || (pvalue == maxpvalue && stat < minstat))
        maxpvalue = pvalue;
        pvalues(var) = pvalue;
        minstat = stat;
        stats(var) = stat;
    end
    
    % Case k > 1
    for k = 2:maxK
        subsets = nchoosek(selectedVars(1:end-1), k-1);       
        for i = 1:size(subsets,1)
            [pvalue, stat] = testFunc(target, var, [subsets(i,:) selectedVars(end)], data, testParams);
        
            if(pvalue > maxpvalue || (pvalue == maxpvalue && stat < minstat))
                maxpvalue = pvalue;
                pvalues(var) = pvalue;
                minstat = stat;
                stats(var) = stat;
            end
        end
    end
end

end