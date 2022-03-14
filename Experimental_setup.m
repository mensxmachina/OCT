clear
clc

addpath(genpath('.\Functions'));
javaaddpath('.\tetradJar\tetrad-gui-6.8.1-launch.jar');

%Repetitions
Nnets=20;    

%Causal hyper-parameters
cdParam.alpha=[0.01, 0.05];
cdParam.penaltyDiscount=[1, 2];
cdParam.structurePrior=[0, 1, 2];
cdParam.algs={'pc', 'cpc', 'pcstable', 'cpcstable', 'fges', 'lingam',...
              'fci', 'fcimax', 'rfci', 'gfci', 'mmhc', 'm3hc'};
%'pc', 'cpc', 'pcstable', 'cpcstable', 'fges', 'lingam',
%'fci', 'fcimax', 'rfci', 'gfci',
%'mmhc', 'm3hc', 'full', 'empty'        
cdParam.indTests={'fisher', 'cci', 'cg_lrt', 'dg_lrt', 'chisquare', 'gsquare'};
%'fisher', 'cci', 'cg_lrt', 'dg_lrt', 'chisquare', 'gsquare'
cdParam.scores={'sembic', 'bdeu', 'discreteBic', 'cg_bic', 'dg_bic'}; 
%'sembic', 'bdeu', 'discreteBic', 'cg_bic', 'dg_bic'


%Simulation parameters
causalbasedSim=false; %true

if causalbasedSim
    
    %Real data
    simParam.nameData='Iris.mat'; 
    %Iris, Wine, HeartDisease, WineQualityRed, BreastCancerWisconsin, 
    %Car, Abalone, ForestFire, StudentMat                      
    
    load(strcat('.\realData\',simParam.nameData));

    %Graph and data type
    graphInfo.causalGraph='DAG';
    if all(isCat)
        graphInfo.dataType='categorical';
        graphInfo.graphType='CatDag';
    elseif all(~isCat)
        graphInfo.dataType='continuous';
        graphInfo.graphType='ConDag';
    else
        graphInfo.dataType='mixed';
        graphInfo.graphType='MixDag';
    end


    %Estimate a DAG and fit the models
    [trueG, trueMec, simParam.Pas, simParam.bestModels,simParam.PerfB, simParam.Residuals]=...
        learnDag_trainModels(realData,isCat, graphInfo);
    simParam.Nnodes=size(realData,2);                 
    simParam.Nedges=nnz(trueG);
    
    simParam.Nsamples=1000;
    
else
    
    %Graph and data type                
    graphInfo.dataType='continuous';   %continuous, categorical, mixed
    graphInfo.causalGraph='DAG';        %DAG, MAG
    graphInfo.graphType='ConDag';       %ConDag, CatDag, MixDag, ConMag, CatMag, MixMag

    %Graph 
    simParam.Nnodes=10;                 
    simParam.Nedges=15;
    simParam.Nsamples=1000;
    simParam.Nlatent=0;               

    %Data 
    if strcmp(graphInfo.dataType, 'mixed')
        simParam.method='LeeHastie';     %LeeHastie, CondGaus      
    elseif strcmp(graphInfo.dataType, 'continuous')
        simParam.func='sumX';           %sumX sumX2 sumX-1 prodX tanh sumabsX logX exp05 exp15 logcosh prode
        simParam.errorDist='gaussian';  %gaussian, uniform    
    end

end


%SID
computeSid=false; %true
