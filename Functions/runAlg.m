function alg = runAlg (algName, IndTest, Score)

    import edu.cmu.tetrad.*
    import java.util.*
    import java.lang.*
    import edu.cmu.tetrad.data.*
    import edu.cmu.tetrad.search.*
    import edu.cmu.tetrad.graph.*   
    import edu.cmu.tetrad.search.SearchGraphUtils.*
    import edu.cmu.tetrad.algcomparison.score.*
    import edu.cmu.tetrad.algcomparison.independence.*
    import edu.cmu.tetrad.util.*

    maxk=-1;
    if strcmp(algName, 'pc')
        alg=Pc(IndTest);  
        alg.setAggressivelyPreventCycles(true);
        alg.setDepth(maxk);      

    elseif strcmp(algName, 'cpc')
        alg=Cpc(IndTest);
        alg.setAggressivelyPreventCycles(true);
        alg.setDepth(maxk);      

    elseif strcmp(algName,'pcstable')
        alg=PcStable(IndTest);
        alg.setAggressivelyPreventCycles(true);
        alg.setDepth(maxk);      

    elseif strcmp(algName, 'cpcstable')
        alg=CpcStable(IndTest);
        alg.setAggressivelyPreventCycles(true);
        alg.setDepth(maxk);      

    elseif strcmp(algName, 'fges')
        alg=Fges(Score);

    elseif strcmp(algName,'lingam')
        alg=Lingam;

    elseif strcmp(algName,'fci')
        alg=Fci(IndTest);   

    elseif strcmp(algName, 'fcimax')
        alg=FciMax(IndTest);

    elseif strcmp(algName, 'rfci')
        alg=Rfci(IndTest);

    elseif strcmp(algName, 'gfci')
        alg=GFci(IndTest, Score);

    else
        alg=[];
    end

end
