
%Causal configurations
Configs=createCombinations(cdParam, graphInfo.graphType);
Nconfigs=size(Configs,1);
fprintf("\n# Configurations:%d", Nconfigs);

timesCD=zeros(Nnets,1);
timesOct=zeros(Nnets,1);
valuesOct=cell(Nnets,1);
SHDs=nan(Nconfigs, Nnets);
DSHDoct=cell(Nnets,1);
configsOct=cell(Nnets,1);

for net=1:Nnets    
    fprintf("\n\n\nNet: %d \n", net); 
    
    %Simulate data
    [trueG,trueMec, data, dataInfo]=simulateGraphData(simParam,graphInfo);

    %Causal discovery on all data
    cdtic=tic;
    [allMecG, allG, ~, ~]=causalDiscovery(data, dataInfo, graphInfo, Configs); 
    timesCD(net,1)=toc(cdtic);
    
    %Tuning with OCT   
    octtic=tic;
    [configsOct{net,1}, valuesOct{net,1}, namesOct]=OutofsampleCausalTuning_metrics(data, Configs, dataInfo, graphInfo);
    timesOct(net,1)=toc(octtic);

    %Evaluation
    [SHD, ~, ~, ~, ~]=computeMetrics(trueMec, trueG, allMecG, graphInfo.causalGraph, computeSid);     
    DSHDoct{net,1}=(SHD(configsOct{net,1})-min(SHD))';
    
    %Save  
    SHDs(:,net)=SHD;    
    Nets.trueG{net,1}=trueG;
    Nets.trueMec{net,1}=trueMec;
    Nets.data{net,1}=data;      
    Nets.dataInfo{net,1}=dataInfo;
    Nets.allMecG{net,1}=allMecG;
    Nets.allG{net,1}=allG;
end
configsOctt=array2table(cell2mat(configsOct), 'VariableNames', namesOct);
DSHDt=array2table(cell2mat(DSHDoct), 'VariableNames', namesOct);


%Results
if strcmp (graphInfo.dataType, 'continuous')
    toPlot={'OCTmu', 'OCTr2', 'OCTrmse'}; 
elseif strcmp (graphInfo.dataType, 'categorical')
    toPlot={'OCTmu', 'OCTauc'}; 
end
fprintf("\nResults (DSHD)");
for m=1:size(toPlot,2)
    fprintf("\n%10s:%5.2f ", toPlot{m},mean(DSHDt.(toPlot{m})));
end
colors=[145 47 82; 185, 150, 23; 101, 63, 151]./255; 
Nmetrics=length(toPlot); 
figure;
for m=1:Nmetrics
    meDag=mean(DSHDt.(toPlot{m}));
    stDag=std(DSHDt.(toPlot{m}))/sqrt(length(DSHDt.(toPlot{m})));
    e=errorbar(m, meDag, stDag);
    e.Marker='o';
    e.MarkerSize=15;
    e.Color=colors(m,:);
    e.MarkerFaceColor='auto';
    e.LineWidth=1;
    e.LineStyle='none';
    hold on
end
grid on
ax=gca;
ax.XTick=[];
ax.XAxis.FontSize = 15;
ax.YAxis.FontSize = 12;
ylim([0,Inf]);
xlim([0, m+2]);
ylabel({sprintf('\\Delta %s','SHD'), " "}, 'FontSize',15);
title('DAGs', 'FontSize',15, 'FontWeight', 'normal');
lgd=legend(toPlot(:));
lgd.FontSize=10;
hold off;

