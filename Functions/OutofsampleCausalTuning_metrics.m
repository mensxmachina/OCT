function [cOct, valsOct, namesOct]=OutofsampleCausalTuning_metrics(data, Configs, dataInfo, graphInfo)

    %OCT parameters
    Nfolds=10;
    Ntrees=100;
    PredSel='interaction-curvature';
    octsAlpha=0.05;
    Nper=1000;

    %Info
    [Nsamples, Nnodes]=size(data);
    Classes=dataInfo.Classes;
    isCat=dataInfo.isCat;
    Nconfigs=size(Configs,1);
    causalGraph=graphInfo.causalGraph;


    % 1. Causal discovery 

    trainData=cell(Nfolds,1);
    testData=cell(Nfolds,1);
    trainMecG=cell(Nfolds,1);
    trainG=cell(Nfolds,1);

    %split data in k folds
    cv = cvpartition(Nsamples, 'KFold', Nfolds);  
    for f=1:Nfolds  
        training=cv.training(f);
        test= cv.test(f);
        trainData{f,1}=data(training,:);
        testData{f,1}=data(test,:);   
    end

    %causal discovery on each fold
    fprintf("\nOut-of-sample Causal Tuning : causal discovery on each fold\n");
    cdfoldtic=tic;
    for f=1:Nfolds
        curTrain=trainData{f,1};
        [trainMecG{f,1}, trainG{f,1}, ~,  ~]=causalDiscovery(curTrain, dataInfo, graphInfo, Configs);
    end 
    timeOct.cdfolds=toc(cdfoldtic);


    % 2. Predictive models 

    MBsize=zeros(Nconfigs, Nfolds);
    poolYs=cell(1, Nnodes);
    poolYhats=cell(Nconfigs, Nnodes);
    poolScores=cell(Nconfigs, Nnodes);
    Mutual=nan(Nconfigs, Nnodes);
    AUC=nan(Nconfigs, Nnodes);
    R2=nan(Nconfigs, Nnodes);
    RMSE=nan(Nconfigs, Nnodes);


    idxs=cell(Nper,1); 
    timeFit=zeros(Nconfigs, Nnodes, Nfolds);
    timePerf=zeros(Nconfigs, Nnodes);

    for node=1:Nnodes
        poolY=[];
        for f=1:Nfolds
            ytest=testData{f,1}(:,node);
            poolY=cat(1,poolY, ytest); 
        end
        poolYs{1,node}=poolY;
    end


    % 2a. Fit models and predict
    fprintf("\nOut-of-sample Causal Tuning : fit predictive models\n");
    fitevaltic=tic;
    for c=1:Nconfigs    
        for node=1:Nnodes

            poolYhat=[];
            poolScore=[];

            for f=1:Nfolds                 
                switch causalGraph
                    case 'DAG' 
                        curG=trainMecG{f,1}{c,1}; 
                        estMBs=pdagToMb(curG);  %curG is a PDAG
                    case 'MAG'
                        curG=trainG{f,1}{c,1}; 
                        estMBs=magToMb(curG);   %curG is a MAG
                end
                MBsize(c,f)=mean(cellfun(@length, estMBs));
                curMb=estMBs{node,1}; 

                ytrain=trainData{f,1}(:,node);
                xtrain=trainData{f,1}(:,curMb);
                ytest=testData{f,1}(:,node);
                xtest=testData{f,1}(:,curMb);
                Ntest=size(ytest,1);

                fittic=tic;
                if isCat(node)
                    if ~isempty(curMb)
                        ClassNames=strsplit(num2str(Classes{1,node}));
                        M=TreeBagger(Ntrees,xtrain,ytrain,...
                            'Method', 'classification', ...
                            'CategoricalPredictors', isCat(curMb),...
                            'PredictorSelection', PredSel,...
                            'ClassNames', ClassNames);
                        [pred, score]=M.predict(xtest);
                        pred=str2double(pred);                    
                    else
                        [~, predVal]=empiricalProb(ytrain);
                        scoreii=zeros(length(Classes{1,node}),1);
                        for j=1:length(Classes{1,node})
                            cj=Classes{1,node}(j);
                            scoreii(j)=nnz(ytrain==cj)/length(ytrain);
                        end
                        pred=ones(Ntest,1).*predVal;
                        score=repmat(scoreii', Ntest, 1);
                    end 

                    poolYhat=cat(1,poolYhat, pred);   
                    poolScore=cat(1,poolScore, score);

                else %isContinuous
                    if ~isempty(curMb)                         
                        M=TreeBagger(Ntrees,xtrain,ytrain,...
                            'Method', 'regression', ...
                            'CategoricalPredictors', isCat(curMb),...
                            'PredictorSelection',PredSel);
                        pred = M.predict(xtest); 
                    else
                        pred=ones(Ntest,1)*mean(ytrain); %predict mean value
                    end

                    poolYhat=cat(1,poolYhat, pred); 
                end  
                timeFit(c,node,f)=toc(fittic);
            end

            poolYhats{c,node}=poolYhat;
            poolScores{c,node}=poolScore;

            %2b. Predictive performance
            mutic=tic;
            if isCat(node)
                Mutual(c,node)=mutualInfoD(poolYs{1,node}, poolYhats{c,node});
                AUC(c,node)=multiAUC(poolYs{1,node}, poolScores{c,node}, Classes{1,node});
            else
                Mutual(c,node)=mutualInfoC(poolYs{1,node}, poolYhats{c,node});
                R2(c,node)=R2metric(poolYs{1,node}, poolYhats{c,node});
                RMSE(c,node) = sqrt(mean((poolYs{1,node} - poolYhats{c,node}).^2));
            end
            timePerf(c,node)=toc(mutic);
        end
    end
    timeOct.fitModels=timeFit;
    timeOct.evalPerf=timePerf;
    timeOct.allPred=toc(fitevaltic);



    %3. Select configuration

    fprintf("\nOut-of-sample Causal Tuning : sparsity penalty\n");
    sparstic=tic;

    for i=1:Nper
        idx=randi([0,1], size(poolYs{1,1},1), 1);
        idxs{i,1}=logical(idx); %for swap
    end

    [OCTmu, OCTsmu, isEqualmu, pvaluesmu]  = permutationTest(isCat, poolYs, poolYhats, poolScores, Classes, ...
        Nper, idxs, 'mutual', Mutual, MBsize, octsAlpha);

    if strcmp(graphInfo.dataType, 'categorical')    
        [OCTauc, OCTsauc, isEqualauc, pvaluesauc]  = permutationTest(isCat, poolYs, poolYhats, poolScores, Classes,...
            Nper, idxs, 'auc', AUC, MBsize, octsAlpha);

    elseif strcmp(graphInfo.dataType, 'continuous')    
        [OCTr2, OCTsr2, isEqualr2, pvaluesr2]   = permutationTest(isCat, poolYs, poolYhats, poolScores, Classes, ...
            Nper, idxs, 'r2', R2, MBsize, octsAlpha);

        [OCTrmse, OCTsrmse, isEqualrmse, pvaluesrmse]  = permutationTest(isCat, poolYs, poolYhats, poolScores, Classes,...
            Nper, idxs, 'rmse', RMSE, MBsize, octsAlpha);

    end

    timeOct.sparsity=toc(sparstic);


    %Save
    cOct(1,1)=OCTmu;
    cOct(1,2)=OCTsmu;
    namesOct={'OCTmaxmu', 'OCTmu'};

    valsOct.Mutual=Mutual;
    valsOct.isEqualmu=isEqualmu;
    valsOct.pvaluesmu=pvaluesmu;

    if strcmp(graphInfo.dataType, 'categorical')
        cOct(1,3)=OCTauc;
        cOct(1,4)=OCTsauc;
        namesOct=[namesOct , {'OCTmaxauc', 'OCTauc'}];

        valsOct.AUC=AUC;
        valsOct.isEqualauc=isEqualauc;
        valsOct.pvaluesauc=pvaluesauc;

    elseif strcmp(graphInfo.dataType, 'continuous')
        cOct(1,3)=OCTr2;
        cOct(1,4)=OCTsr2;
        cOct(1,5)=OCTrmse;
        cOct(1,6)=OCTsrmse;
        namesOct=[namesOct , {'OCTmaxr2', 'OCTr2', 'OCTminrmse', 'OCTrmse'}];

        valsOct.R2=R2;
        valsOct.RMSE=RMSE;

        valsOct.isEqualr2=isEqualr2;
        valsOct.pvaluesr2=pvaluesr2;
        valsOct.isEqualrmse=isEqualrmse;
        valsOct.pvaluesrmse=pvaluesrmse;
    end

    valsOct.MBsize=MBsize;
    valsOct.poolYs=poolYs;
    valsOct.poolYhats=poolYhats;
    valsOct.poolScores=poolScores;
    valsOct.trainData=trainData;
    valsOct.testData=testData;
    valsOct.trainMecG=trainMecG;
    valsOct.trainG=trainG;
    valsOct.timeOct=timeOct;

end
