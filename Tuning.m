
%Causal configurations
Configs=createCombinations(cdParam, graphInfo.graphType);
Nconfigs=size(Configs,1);
fprintf("\n# Configurations:%d", Nconfigs);

%time 
timesCD=zeros(Nnets,1);
timesScores=zeros(Nnets,1);
timesOct=zeros(Nnets,1);
timesStars=zeros(Nnets,1);

%info from tuning methods
configsOct=cell(Nnets,1);
configsScores=cell(Nnets,1);
configsStars=cell(Nnets,1);
configsRnd=cell(Nnets,1);
valuesOct=cell(Nnets,1);
valuesScores=cell(Nnets,1);
valuesStars=cell(Nnets,1);

%metrics: Nconfigs * Nnets
SHDs=nan(Nconfigs, Nnets);
SIDus=nan(Nconfigs, Nnets);
SIDls=nan(Nconfigs, Nnets);
APs=nan(Nconfigs, Nnets);
ARs=nan(Nconfigs, Nnets);

%delta_metrics
DSHD=cell(Nnets, 1);
DSIDu=cell(Nnets, 1);
DSIDl=cell(Nnets, 1);
DAP=cell(Nnets, 1);
DAR=cell(Nnets, 1);


for net=1:Nnets    
    fprintf("\n\n\nNet: %d \n", net); 
      
    %Simulate data
    if causalbasedSim
        [data,dataInfo] = resimulate_data(realData, simParam, isCat);
    else
        [trueG,trueMec, data, dataInfo]=simulateGraphData(simParam,graphInfo);
    end
    
    %Causal discovery on all data
    cdtic=tic;
    [allMecG, allG, ~, ~]=causalDiscovery(data, dataInfo, graphInfo, Configs); 
    timesCD(net,1)=toc(cdtic);
    
    %Tuning with OCT   
    octtic=tic;
    [configsOct{net,1}, valuesOct{net,1}, namesOct]=OutofsampleCausalTuning(data, Configs, dataInfo, graphInfo);
    timesOct(net,1)=toc(octtic);
    
    %Tuning with scores 
    scoretic=tic;
    [configsScores{net,1}, valuesScores{net,1}, namesScores]= ScoresTuning(data, allG, dataInfo, graphInfo);
    timesScores(net,1)=toc(scoretic);
    
    %Tuning with StARS
    starstic=tic;
    [configsStars{net,1}, valuesStars{net,1}]=StarsTuning(data, dataInfo,graphInfo, Configs);    
    timesStars(net,1)=toc(starstic);
    
    %Random Choice
    configsRnd{net,1}=randi(Nconfigs);
    
    
    %Evaluation
    [SHD, SIDu, SIDl, AP, AR]=computeMetrics(trueMec, trueG, allMecG, graphInfo.causalGraph, computeSid); 
    
    [DSHD{net,1}, DSIDu{net,1}, DSIDl{net,1}, DAP{net,1}, DAR{net,1}, namesTuningAll]=...
        distanceOracle(SHD, SIDu, SIDl, AP, AR,...
        configsOct{net,1}, configsScores{net,1}, configsStars{net,1}, configsRnd{net,1},...
        namesOct, namesScores);
   
    
    %Save   
    SHDs(:,net)=SHD;
    SIDus(:,net)=SIDu;
    SIDls(:,net)=SIDl;
    APs(:,net)=AP;
    ARs(:,net)=AR;
    

    Nets.trueG{net,1}=trueG;
    Nets.trueMec{net,1}=trueMec;
    Nets.data{net,1}=data;      
    Nets.dataInfo{net,1}=dataInfo;
    Nets.allMecG{net,1}=allMecG;
    Nets.allG{net,1}=allG;
end


%Results
DSHDt=array2table(cell2mat(DSHD), 'VariableNames', namesTuningAll);
DAPt=array2table(cell2mat(DAP), 'VariableNames', namesTuningAll);
DARt=array2table(cell2mat(DAR), 'VariableNames', namesTuningAll);
if ~isnan(SIDus)
    DSIDut=array2table(cell2mat(DSIDu), 'VariableNames', namesTuningAll);
    DSIDlt=array2table(cell2mat(DSIDl), 'VariableNames', namesTuningAll);
end

configsAllt=array2table([cell2mat(configsOct),...
                        cell2mat(configsScores),...
                        cell2mat(configsStars),...
                        cell2mat(configsRnd)],...
                        'VariableNames', namesTuningAll(1:end-1));

%Print results
fprintf("\nResults (DSHD)");
for m=2:size(namesTuningAll, 2)
    fprintf("\n%10s : %5.2f", namesTuningAll{m}, mean(DSHDt.(namesTuningAll{m})));
end

%Plot results
plotResults(graphInfo,namesTuningAll, DSHDt)

