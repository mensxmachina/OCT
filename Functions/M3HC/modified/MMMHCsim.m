function [mmmhcMag, mmmhc_bs, mmmhcIters, mmmhc, skeleton_final, time] = MMMHCsim(obsData, maxCondSet, threshold, tol, cor, tabu, TABUsize, skeleton)
%------
%kbiza, 3/4/21
%change input
%old input: Dataset (Dataset.data, Dataset.isLatent) that includes latent
%variables
%new input : obsData that includes only observed variables
%------

t = tic;
nSamples = size(obsData,1);
nVarsObs=size(obsData,2);

if cor == logical(true)
    covMat = corr(obsData);
else
    covMat = cov(obsData);
end

if strcmp(skeleton,'MMPC')
    testParams = struct('N', nSamples);
    graph3 = MMPCskeleton(covMat, maxCondSet, threshold, @FisherTestFast, testParams);
    
    for i = 1:nVarsObs
        skeleton_final{1,i} = find(graph3(i,:)==1);
    end
    
elseif  strcmp(skeleton,'SES')
    
    data = obsData;
    options.maxK = maxCondSet;
    options.test = 'testIndFisher_ses';
    options.threshold = threshold;
    
    for i = 1:size(data,2)
        i;
        y = data(:,i);
        test_data = [data(:,1:i-1) data(:,i+1:end)];
        [selectedVars, pvalues, stats, queues] = SES(y, test_data, covMat, options);
        
        for k = 1:size(selectedVars,2)
            if selectedVars(1,k)>=i
                selectedVars(1,k) = selectedVars(1,k)+1;
            end
            if cell2mat(queues(1,k))>=i
                queues{1,k} = queues{1,k}+1;
            end
        end
        
        selectedVars_f{1,i} = selectedVars;
        pvalues_f(i,:) = pvalues;
        stats_f(i,:) = stats;
        queues_f1{1,i} = cell2mat(queues);
        queues_f2{1,i} = queues;
    end
    
    dummy = selectedVars_f;
    for i = 1:size(data,2); dummy{2,i} = queues_f1{1,i};
    end
    for i = 1:size(data,2); dummy{3,i} = unique([dummy{1,i} dummy{2,i}]);
        skely{1,i} = unique([dummy{1,i}]);
    end
    skeleton_final = dummy(3,:);
%     skeleton_final = skely;    
end

% for i = 1:size(data,2); skelety{1,i} = unique([mmpc_final{1,i} skeleton_final{1,i}]);
%     end



time(1,1) = toc(t);
% load('lala.mat'); mmpc_final = mmpc_final2;
if tabu == logical(false)
    [mmmhcMag, mmmhc_bs, mmmhcIters, mmmhc, time(1,2:4)] = mmmhcSearchMag(covMat, nSamples, tol, false, skeleton_final);
else
    [mmmhcMag, mmmhc_bs, mmmhcIters, mmmhc, time(1,2:4)] = mmmhcSearchMagTABU(covMat, nSamples, tol, skeleton_final, TABUsize);
end

% time(1,5) = 0;

end