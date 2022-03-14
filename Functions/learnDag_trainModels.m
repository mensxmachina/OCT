function [trueG, trueMec,Pas, bestModels,PerfB,Residuals]= learnDag_trainModels(realData,isCat, graphInfo)

    ConfigVNames={'alg','indTest', 'score', 'alpha', 'penaltyDiscount', 'structurePrior'};
    if all(isCat)
        Config= table({'fges'},{'none'},{'discreteBic'}, 0.01, 1, 1,'VariableNames',ConfigVNames);
    elseif all(~isCat)
        Config= table({'fges'},{'none'},{'sembic'}, 0.01, 1, 1,'VariableNames',ConfigVNames);
    else
        Config= table({'fges'},{'none'},{'cg_bic'}, 0.01, 1, 1,'VariableNames',ConfigVNames);
    end    

    %DataInfo
    Nnodes=size(realData,2);
    ClassesReal=cell(1,Nnodes);
    NdomainReal=zeros(1,Nnodes);
    for node=1:Nnodes
        if isCat(node)
            ClassesReal{1,node}=unique(realData(:,node))';
            NdomainReal(1,node)=max(ClassesReal{1,node})+1; %[0,1,...,maxC]
        end
    end
    dataInfoReal.Classes=ClassesReal;
    dataInfoReal.Ndomain=NdomainReal;
    dataInfoReal.isCat=isCat;

    %Estimate a graph and fit the models
    [MecG, G, ~, ~]=causalDiscovery(realData, dataInfoReal, graphInfo, Config);
    trueG=G{1,1};
    trueMec=MecG{1,1};

    [Pas, Npa]=parents(trueG);
    [bestModels,PerfB,Residuals] = TRAIN(realData,Pas, isCat,ClassesReal);

end
