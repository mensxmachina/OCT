% data: NxM matrix with N samples and M variables
% target: index of target in data
% maxK: maximum conditioning set size
% threshold: significance level alpha
% testFunc: @function(X, Y, Z, data, testParams)
    % X: index of variable X in data
    % Y: index of variable Y in data
    % Z: vector of indices of conditioning variables in data
% testParams: struct containing additional information required for the test

function [selectedVars] = MMPC(data, target, maxK, threshold, testFunc, testParams, dataset)
nvars = size(data,2);
pvalues = ones(nvars, 1);
stats = zeros(nvars, 1);

remainingVars = true(nvars,1);
remainingVars(target) = false;
selectedVars = [];

% Forward Phase
while any(remainingVars)
    [curvar, curpvalue, remainingVars, pvalues, stats] = findMaxMinAssociation(data, target, maxK, selectedVars, remainingVars, pvalues, stats, testFunc, testParams, dataset, threshold);
    
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
   curpvalue = findMinAssociation(data, target, curvar, maxK, curSelectedVars, pvalues, stats, testFunc, testParams, dataset, threshold);
   if(curpvalue > threshold)
       toremove(idx(i)) = true;
   else
       curSelectedVars = [curSelectedVars curvar];
   end
end
selectedVars(toremove) = [];

end

function  [bestvar, bestpvalue, remainingVars, pvalues, stats] = findMaxMinAssociation(data, target, maxK, selectedVars, remainingVars, pvalues, stats, testFunc, testParams, dataset, threshold)

bestvar = [];
bestpvalue = Inf;
beststat = -Inf;

for var = 1:length(remainingVars)
    if(remainingVars(var))
        [curpvalue, curstat, pvalues, stats] = findMinAssociation(data, target, var, maxK, selectedVars, pvalues, stats, testFunc, testParams, dataset, threshold);
        if(curpvalue < bestpvalue || (curpvalue == bestpvalue && curstat > beststat))
            bestvar = var;
            bestpvalue = curpvalue;
            beststat = curstat;
        end
    end
end

end

function [maxpvalue, minstat, pvalues, stats] = findMinAssociation(data, target, var, maxK, selectedVars, pvalues, stats, testFunc, testParams, dataset, threshold)

maxpvalue = pvalues(var);
minstat = stats(var);
    
maxK = min([maxK length(selectedVars)]);


%           options.maxK = maxK;
%           test = 'testIndFisher_mmpc';
%           options.threshold = threshold;
%           data2 = dataset.data(:, ~dataset.isLatent);
%             y = data2(:,target);
%           test_data = [data2(:,1:target-1) data2(:,target+1:end)];

if(maxK == 0)
    [pvalue, stat] = testFunc(target, var, [], data, testParams);
          
%           if var>target
%                [pvalue2, stat2] = feval(test, y, test_data, var-1, []);
%           elseif var<target
%              [pvalue2, stat2] = feval(test, y, test_data, var, []);
%           end
%           [pvalue pvalue2; stat stat2];
%           if abs(pvalue-pvalue2)>0.0001 || abs(stat-stat2)>0.0001
%               display('something is wrong')
%           end
%             pvalue=pvalue2;
%             stat=stat2;
    
    maxpvalue = pvalue;
    pvalues(var) = pvalue;
    minstat = stat;
    stats(var) = stat;
else
    % Case k = 1
    [pvalue, stat] = testFunc(target, var, selectedVars(end), data, testParams);
    
%            selectedVars2 = selectedVars(end);
%            selectedVars3 = selectedVars2;
%            selectedVars3(selectedVars2>target) = selectedVars3(selectedVars2>target)-1;
%             if var>target
%               [pvalue2, stat2] = feval(test, y, test_data, var-1, selectedVars3);
%             elseif var<target
%               [pvalue2, stat2] = feval(test, y, test_data, var, selectedVars3);
%             end
%            [pvalue pvalue2; stat stat2];
%            if abs(pvalue-pvalue2)>0.0001 || abs(stat-stat2)>0.0001
%               display('something is wrong')
%            end
%               pvalue=pvalue2;
%               stat=stat2;
    
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
            
            
            
%                  selectedVars2 = [subsets(i,:) selectedVars(end)];
%                  selectedVars3 = selectedVars2;
%                  selectedVars3(selectedVars2>target) = selectedVars3(selectedVars2>target)-1;
%                  if var>target
%                     [pvalue2, stat2] = feval(test, y, test_data, var-1, selectedVars3);
%                  elseif var<target
%                     [pvalue2, stat2] = feval(test, y, test_data, var, selectedVars3);
%                  end
%                  [pvalue pvalue2; stat stat2];
%                  if abs(pvalue-pvalue2)>0.0001 || abs(stat-stat2)>0.0001
%                     display('something is wrong')
%                  end
%                       pvalue=pvalue2;
%                       stat=stat2;
%          
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