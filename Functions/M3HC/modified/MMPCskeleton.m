%----------------
%kbiza, 3/4/21, 
%   delete input : dataset 
%----------------


% data: NxM matrix with N samples and M variables
% maxK: maximum conditioning set size
% threshold: significance level alpha
% testFunc: @function(X, Y, Z, data, testParams)
    % X: index of variable X in data
    % Y: index of variable Y in data
    % Z: vector of indices of conditioning variables in data
% testParams: struct containing additional information required for the test

% Returns the MMPC skeleton (graph), as well as the selected variables for each node (pcs)
function [graph, pcs] = MMPCskeleton(data, maxK, threshold, testFunc, testParams)

nvars = size(data,2);

% First Phase
pcs = cell(nvars,1);
for i = 1:nvars
    pcs{i} = MMPCmod(data, i, maxK, threshold, testFunc, testParams);
end

% Second Phase
toremove = cell(nvars,1);
for i = 1:nvars
   for j = 1:length(pcs{i})
       var = pcs{i}(j);
       if(~any(pcs{var} == i))
           toremove{i} = [toremove{i} var];
           toremove{var} = [toremove{var} i];
       end
   end
end

for i = 1:nvars
   pcs{i} = setdiff(pcs{i}, toremove{i}); 
end

% Create Undirected Graph
graph = zeros(nvars, nvars);
for i = 1:nvars
   graph(i,pcs{i}) = 1; 
   graph(pcs{i},i) = 1; 
end

end

