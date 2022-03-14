function scoreOut=scoreMap(scoreIn, graphType)

    ConDagScores={'sembic', 'cci', 'cg_bic','dg_bic'};  
    CatDagScores={'bdeu','discreteBic','cg_bic','dg_bic'};
    MixDagScores={'cg_bic','dg_bic'};
    ConMagScores={'sembic', 'cci', 'cg_bic','dg_bic'};
    CatMagScores={'bdeu','discreteBic','cg_bic','dg_bic'};
    MixMagScores={'cg_bic','dg_bic'};

    if isnan(scoreIn)
        scoreOut='none';
    elseif isnumeric(scoreIn)
        switch graphType
            case 'ConDag'
                scoreOut=ConDagScores{scoreIn};   
            case 'CatDag'
                scoreOut=CatDagScores{scoreIn}; 
            case 'MixDag'
                scoreOut=MixDagScores{scoreIn}; 
            case 'ConMag'
                scoreOut=ConMagScores{scoreIn}; 
            case 'CatMag'
                scoreOut=CatMagScores{scoreIn};
            case 'MixMag'
                scoreOut=MixMagScores{scoreIn};
            otherwise
                fprintf("\n problehm with causalm");
        end
        
    elseif ischar(scoreIn)
        switch graphType
            case 'ConDag'
                scoreOut=find(strcmp(ConDagScores, scoreIn));   
            case 'CatDag'
                scoreOut=find(strcmp(CatDagScores, scoreIn)); 
            case 'MixDag'
                scoreOut=find(strcmp(MixDagScores, scoreIn)); 
            case 'ConMag'
                scoreOut=find(strcmp(ConMagScores, scoreIn)); 
            case 'CatMag'
                scoreOut=find(strcmp(CatMagScores, scoreIn));
            case 'MixMag'
                scoreOut=find(strcmp(MixMagScores, scoreIn));
            otherwise
                fprintf("\n problehm with causalm");
        end
    end
    
end   
