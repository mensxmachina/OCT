function [dag, pdag, data]=simulateTetrad(simParam)

    import edu.cmu.tetrad.util.*
    import edu.cmu.tetrad.algcomparison.simulation.*
    import edu.cmu.tetrad.algcomparison.graph.*;
    import edu.cmu.tetrad.sem.*
    import edu.cmu.tetrad.search.*
    import edu.cmu.tetrad.search.SearchGraphUtils.*

    G=RandomForward; 
    
    parameters=Parameters;
    parameters.set("numMeasures", simParam.Nnodes);
    parameters.set("sampleSize", simParam.Nsamples);
    parameters.set("avgDegree", simParam.avgDegree);
    parameters.set("maxDegree", simParam.maxDegree);
    parameters.set("differentGraphs",true);
    parameters.set("numRuns", 1);
    parameters.set("numLatents", 0);    
    parameters.set("randomizeColumns", false); %!! 
    
    
    if strcmp(simParam.method, 'gsem')       
        parameters.set('generalSemFunctionTemplateMeasured', simParam.Function);
        parameters.set('generalSemErrorTemplate', simParam.Error);
        parameters.set('generalSemParameterTemplate', simParam.Coef);
        
        Sim=GeneralSemSimulation(G);
        
    elseif strcmp(simParam.method, 'LeeHastie')  
        parameters.set("minCategories", simParam.minC);
        parameters.set("maxCategories", simParam.maxC);
        parameters.set("percentDiscrete", simParam.percD);
        
        Sim=LeeHastieSimulation(G); 
    
    elseif strcmp(simParam.method, 'Bayes')        
        parameters.set("minCategories", simParam.minC);
        parameters.set("maxCategories", simParam.maxC);
        parameters.set("maxDegree", simParam.maxDegree);
        Sim=BayesNetSimulation(G);
        
    elseif strcmp(simParam.method, 'CondGaus')
        parameters.set("minCategories", simParam.minC);
        parameters.set("maxCategories", simParam.maxC);
        parameters.set("maxDegree", simParam.maxDegree);
        Sim=ConditionalGaussianSimulation(G);
    end
    
    Sim.createData(parameters, true);
    tDag=Sim.getTrueGraph(0);
    tData=Sim.getDataModel(0); %the nodes/columns should be in order
    
    %works only for gsem
    %ims=Sim.getIms;
    %im=ims.get(0);
    %tData=im.simulateData(Nsamples,false);
    
    tpdag=patternFromDag(tDag);
    
    dag=tetradToMatrix(tDag);
    pdag=tetradToMatrix(tpdag);

    data=zeros(simParam.Nsamples, simParam.Nnodes);
    for row=1:simParam.Nsamples
        for col=1:simParam.Nnodes
            data(row,col)=tData.getDouble(row-1, col-1);
        end
    end

end
