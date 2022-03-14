function testOut=indTestMap(testIn, causalM)

    ConDagTests={'fisher', 'kci', 'cci','cg_lrt','dg_lrt'};  
    CatDagTests={'chisquare', 'gsquare','cg_lrt','dg_lrt'};
    MixDagTests={'cg_lrt','dg_lrt'};
    ConMagTests={'fisher', 'kci', 'cci','cg_lrt','dg_lrt'};
    CatMagTests={'chisquare', 'gsquare','cg_lrt','dg_lrt'};
    MixMagTests={'cg_lrt','dg_lrt'};
    
    if isnan(testIn)
        testOut='none';
        
    elseif isnumeric(testIn)
        switch causalM
            case 'ConDag'
                testOut=ConDagTests{testIn};   
            case 'CatDag'
                testOut=CatDagTests{testIn}; 
            case 'MixDag'
                testOut=MixDagTests{testIn}; 
            case 'ConMag'
                testOut=ConMagTests{testIn}; 
            case 'CatMag'
                testOut=CatMagTests{testIn};
            case 'MixMag'
                testOut=MixMagTests{testIn};
            otherwise
                fprintf("\n problehm with causalm");
        end
        
    elseif ischar(testIn)
        switch causalM
            case 'ConDag'
                testOut=find(strcmp(ConDagTests, testIn));   
            case 'CatDag'
                testOut=find(strcmp(CatDagTests, testIn)); 
            case 'MixDag'
                testOut=find(strcmp(MixDagTests, testIn)); 
            case 'ConMag'
                testOut=find(strcmp(ConMagTests, testIn)); 
            case 'CatMag'
                testOut=find(strcmp(CatMagTests, testIn));
            case 'MixMag'
                testOut=find(strcmp(MixMagTests, testIn));
            otherwise
                fprintf("\n problehm with causalm");
        end
    end
    
end
    