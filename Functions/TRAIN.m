function [bestModels,PerfB, Residuals] = TRAIN(data,Pas, isCat, Classes)

    Nfolds=10;
    [Ninsamples,Nnodes]=size(data);

    %predictive configurations
    PredConfigsNames={'alg','kernel', 'Ntrees'};
    svm1= table({'svm'},{'linear'},nan, 'VariableNames',PredConfigsNames);
    svm2= table({'svm'},{'rbf'},   nan, 'VariableNames',PredConfigsNames);
    rf1 = table({'rf'}, {'none'},  100, 'VariableNames',PredConfigsNames);

    PredConfigs=[svm1; svm2; rf1];
    Nconfigs=size(PredConfigs,1);

    %Split in k folds
    cv = cvpartition(Ninsamples, 'KFold', Nfolds);  
    Trains=cell(Nfolds,1);
    Tests=cell(Nfolds,1);  
    for f=1:Nfolds 
        Trains{f,1}=data(cv.training(f),:);
        Tests{f,1}=data(cv.test(f),:); 
    end  

    Residuals=nan(Ninsamples, Nnodes);
    bestModels=cell(Nnodes,1);
    Perf=nan(Nnodes, Nconfigs);
    PerfB=nan(Nnodes,1);


    fprintf("\nFitModels");
    for node=1:Nnodes
        curPa=Pas{node};
        catPred=isCat(curPa);

        fprintf("\nNode:%d, Pa:%s", node, sprintf("%d ", curPa));    

        if isempty(curPa)
            continue
        end

        for m=1:Nconfigs        
            poolY=[];
            poolPred=[];
            poolScores=[];

            for f=1:Nfolds  
                ytrain=Trains{f,1}(:,node);
                xtrain=Trains{f,1}(:,curPa);
                ytest=Tests{f,1}(:,node);
                xtest=Tests{f,1}(:,curPa);

                poolY=cat(1,poolY, ytest); 

                if isCat(node)
                    ClassNames=strsplit(num2str(Classes{1,node}));                
                    [~,~,scores]=fitCModel(xtrain,ytrain,xtest, PredConfigs(m,:), catPred, ClassNames);       
                    poolScores=cat(1,poolScores, scores); 
                else
                    [~,pred]=fitRModel(xtrain,ytrain,xtest, PredConfigs(m,:), catPred);
                    poolPred=cat(1,poolPred, pred);
                end 
            end

            if isCat(node)
                Perf(node,m)=multiAUC(poolY, poolScores, Classes{1,node});
            else
                Perf(node,m)=R2metric(poolY, poolPred);
            end
        end

        %train on all data with the best model
        [~,mstar]=max(Perf(node,:));
        x=data(:,curPa); 
        y=data(:,node);
        if isCat(node)
            ClassNames=strsplit(num2str(Classes{1,node}));           
            [BestMdl,~, scores]=fitCModel(x,y,x, PredConfigs(mstar,:), catPred, ClassNames);
            PerfB(node,1) =multiAUC(y, scores, Classes{1,node});
        else
            [BestMdl, yhat]=fitRModel(x,y,x,PredConfigs(mstar,:), catPred);
            PerfB(node,1) =R2metric(y, yhat);
            Residuals(:,node)=yhat-y;
        end 
        bestModels{node,1}=BestMdl;
        bestModels{node,2}=PredConfigs.alg{mstar};
    end

end



function [Cmdl,pred, scores]=fitCModel(xtrain,ytrain,xtest, config, catPred, ClassNames)

    if strcmp(char(config.alg), 'svm')
        t=templateSVM('KernelFunction', char(config.kernel));
        Cmdl=fitcecoc(xtrain,ytrain, 'Learners', t,...
            'CategoricalPredictors',  catPred,...
            'FitPosterior',true,...
            'ClassNames', ClassNames);
        [pred,~,~,scores] = predict(Cmdl, xtest);
        
    elseif strcmp(char(config.alg), 'rf')
        Cmdl=TreeBagger(config.Ntrees, xtrain, ytrain, ...
              'Method', 'classification', ...
              'CategoricalPredictors',  catPred,... 
              'PredictorSelection','interaction-curvature',...
              'ClassNames', ClassNames);
         [pred,scores] = predict(Cmdl, xtest);
    end    
    pred=str2double(pred); 
end



function [Rmdl,pred]=fitRModel(xtrain,ytrain,xtest, config, catPred)

    if strcmp(char(config.alg), 'svm')
        Rmdl=fitrsvm(xtrain,ytrain,'Standardize',true,...
            'KernelFunction',char(config.kernel),...
            'CategoricalPredictors',  catPred);
        
    elseif strcmp(char(config.alg), 'rf')
        Rmdl=TreeBagger(config.Ntrees,xtrain,ytrain, ...
              'Method', 'regression', ...
              'CategoricalPredictors',  catPred,... 
              'PredictorSelection','interaction-curvature');
    end
    pred=predict(Rmdl, xtest);
end
