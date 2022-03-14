function [trueG, trueMec,data, dataInfo]=simulateGraphData(simParam,graphInfo)

    Nnodes=simParam.Nnodes;
    Nedges=simParam.Nedges;
    Nsamples=simParam.Nsamples;

    %Parameters
    minMi=0;   
    maxMi=0;
    minSigma=0.1;
    maxSigma=1;
    minBeta=0.1;
    maxBeta=0.9;
    simParam.errorU=[-1,1];
    simParam.percD=50;  %percent of Discrete vars
    simParam.minC=2;    %min number of categories 
    simParam.maxC=5;    %max number of categories

    syn=Nedges/Nnodes;
    avg=round(2*syn);
    simParam.maxDegree=avg+1; 
    simParam.avgDegree=avg;
    %-----------------

    if strcmp(graphInfo.dataType, 'categorical')       
        trueDag=createDag(Nnodes, Nedges);  
        [nodes,domainCounts] = dag2randBN(trueDag, 'discrete','minNumStates',...
                                        simParam.minC,'maxNumStates',simParam.maxC); 
        Dataset = simulatedata(nodes, Nsamples,'discrete','domainCounts',domainCounts);
        data=Dataset.data;
        isCat=true(1,Nnodes); 

    elseif strcmp(graphInfo.dataType, 'continuous')    
        trueDag=createDag(Nnodes, Nedges);
        [nodes,~] = dag2randBN(trueDag, 'gaussian',...
                                    'miMinValue', minMi,'miMaxValue',maxMi, ...
                                    'sMinValue', minSigma,'sMaxValue', maxSigma,...
                                    'betaMinValue',minBeta,'betaMaxValue',maxBeta);                    
        data = simulateContinuous(nodes, simParam);
        isCat=false(1,Nnodes);

    elseif strcmp(graphInfo.dataType, 'mixed')
        [trueDag, ~, data]=simulateTetrad(simParam);
        isCat=isCategorical(data);
    end

    if strcmp(graphInfo.causalGraph, 'MAG')
        %latent variables
        Nlatent=simParam.Nlatent;
        isLatent=false(1, Nnodes);
        idxL=randperm(Nnodes,Nlatent);
        isLatent(idxL)=true;

        %Convert Dag to Mag
        Latents = find(isLatent)';
        trueMag = convertDagToMag(trueDag, Latents, []);   

        %delete latent variables
        data(:, isLatent)=[];
        isCat(:, isLatent)=[];

        Nnodes=Nnodes-Nlatent;
        trueG=trueMag;
        trueMec = mag2pag(trueMag);
    else
        trueG=trueDag;
        cpdag=dag2cpdag(trueDag,false);
        trueMec=graphOne(cpdag);
    end

    %DataInfo
    Classes=cell(1,Nnodes);
    Ndomain=zeros(1,Nnodes);
    for node=1:Nnodes
        if isCat(node)
            Classes{1,node}=unique(data(:,node))';
            Ndomain(1,node)=max(Classes{1,node})+1; %[0,1,...,maxC]
        end
    end

    dataInfo.Classes=Classes;
    dataInfo.Ndomain=Ndomain;
    dataInfo.isCat=isCat;

end
