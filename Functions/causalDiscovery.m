function [MecGs, Gs, tMecGs, tGs]=causalDiscovery(data, dataInfo,graphInfo, Configs)

    causalGraph=graphInfo.causalGraph;
    Ndomain=dataInfo.Ndomain;
    Nconfigs=size(Configs,1);
    MecGs=cell(Nconfigs,1);
    tMecGs=cell(Nconfigs,1);
    Gs=cell(Nconfigs,1);
    tGs=cell(Nconfigs,1);
    Nnodes=size(data,2);

    for c=1:Nconfigs
        config=Configs(c,:);

        if strcmp(config.alg, 'mmhc')
            [Pdag, Dag]=mmhc(data, Ndomain, config.alpha);        
            MecGs{c,1}=Pdag;
            Gs{c,1}=Dag;

        elseif strcmp(config.alg, 'm3hc')
            [Pag, Mag]=m3hc(data, config.alpha);        
            MecGs{c,1}=Pag;
            Gs{c,1}=Mag;

        elseif strcmp(config.alg, 'full')  
            [MecGs{c,1},Gs{c,1}]=fullGraph(Nnodes, causalGraph);

        elseif strcmp(config.alg, 'empty')
            [MecGs{c,1}, Gs{c,1}]=emptyGraph(Nnodes);

        else
            [MecGs{c,1}, tMecGs{c,1}, Gs{c,1}, tGs{c,1}]=tetradAlgs(config,data, dataInfo, graphInfo);
        end    
    end

end
