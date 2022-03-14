function [cScores,valsScores, namesScores]= ScoresTuning (data, allG, dataInfo, graphInfo)

    %scores parameters
    ScoreParams.structurePrior=1;
    ScoreParams.penaltyDiscount=1;
    ScoreParams.discretize=true;

    %info
    Nsamples=size(data,1);
    graphType=graphInfo.graphType;
    dataType=graphInfo.dataType;
    Ndomain=dataInfo.Ndomain;
    isCat=dataInfo.isCat;
    Nconfigs=length(allG);

    %scores
    BIC=nan(Nconfigs,1);
    AIC=nan(Nconfigs,1);
    CG=nan(Nconfigs,1);
    DG=nan(Nconfigs,1);
    cScores=[];
    valsScores=[];
    namesScores={};


    %compute scores
    if strcmp(graphType, 'ConDag') || strcmp(graphType, 'CatDag')
        fprintf("\nTuning with BIC and AIC\n");
        for c=1:Nconfigs
            curG=allG{c,1};
            BIC(c,1)=BicAicScore(curG, data, dataType, Ndomain, 1);
            AIC(c,1)=BicAicScore(curG, data, dataType, Ndomain, 2/log(Nsamples));
        end
        [~,BICc]=max(BIC);
        [~,AICc]=max(AIC);

        valsScores(:,1)=BIC;
        valsScores(:,2)=AIC;   
        cScores(1,1)=BICc;
        cScores(1,2)=AICc;
        namesScores={'BIC', 'AIC'};

    elseif strcmp(graphType, 'MixDag')
        fprintf("\nTuning with CG and DG\n");
        for c=1:Nconfigs
            curG=allG{c,1};
            CG(c,1)=CgDgScore(curG,data, isCat, Ndomain,'cg-bic', ScoreParams);
            DG(c,1)=CgDgScore(curG,data, isCat, Ndomain, 'dg-bic',ScoreParams);
        end
        [~,CGc]=max(CG);
        [~,DGc]=max(DG); 

        valsScores(:,1)=CG;
        valsScores(:,2)=DG;  
        cScores(1,1)=CGc;
        cScores(1,2)=DGc;
        namesScores={'CG', 'DG'};

    elseif strcmp(graphType, 'ConMag')
        fprintf("\nTuning with BIC\n");
        BIC=nan(Nconfigs,1);
        for c=1:Nconfigs
            curG=allG{c,1};
            BIC(c,1)= BICmag(curG, data, 10e-3);
        end 
        [~,BICc]=min(BIC);
        valsScores(:,1)=BIC;
        cScores(1,1)=BICc;
        namesScores={'BIC'};

    end   

end
