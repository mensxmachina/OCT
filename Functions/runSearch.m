function  [MecG, tMecG, G, tG]= runSearch(alg, algName, ds, graphType)

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

    if strcmp(graphType, 'ConDag') || strcmp(graphType, 'CatDag') || strcmp(graphType, 'MixDag')

        if strcmp(algName, 'lingam')
            tDag=alg.search(ds);
            tPdag=patternFromDag(tDag);
            Dag=tetradToMatrix(tDag);
            Pdag=tetradToMatrix(tPdag);
        else   
            tPdag=alg.search();
            if strcmp(algName, 'cpc') || strcmp(algName, 'cpcstable')
                tPdag=patternFromEPattern(tPdag);
            end
            Pdag=tetradToMatrix(tPdag);

            %try to find a DAG
            iterator=DagInPatternIterator(tPdag, false);
            flag=1;          
            while iterator.hasNext
                curtDag=iterator.next;                
                curDag=tetradToMatrix(curtDag);
                [curPa,~]=parents(curDag);
                if isDAG(curPa)
                    tDag=curtDag;
                    Dag=curDag;
                    flag=0;
                    break
                end
            end
            if flag %if no DAG 
                curtDag=dagFromPattern(tPdag);                
                curDag=tetradToMatrix(curtDag);
                tDag=curtDag;
                Dag=curDag;
            end
        end

        MecG=Pdag;
        G=Dag;
        tMecG=tPdag;
        tG=tDag;

    elseif strcmp(graphType, 'ConMag') || strcmp(graphType, 'CatMag') || strcmp(graphType, 'MixMag') 
         tPag=alg.search(); 
         tMag=pagToMag(tPag);    
         Pag=tetradToMatrixL(tPag);
         Mag=tetradToMatrixL(tMag);

         MecG=Pag;
         G=Mag;
         tMecG=tPag;
         tG=tMag;
    end
                
end
