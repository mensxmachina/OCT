function algOut=algMap(algIn, graphType)

    ConDagAlgs={'pc';'cpc'; 'pcstable'; 'cpcstable';...
                'fges';'lingam';'full'; 'empty'};
    CatDagAlgs={'pc';'cpc'; 'pcstable'; 'cpcstable';...
                'fges'; 'mmhc'; 'full'; 'empty'};
    MixDagAlgs={'pc';'cpc'; 'pcstable'; 'cpcstable';...
                'fges'; 'full'; 'empty'};
    ConMagAlgs={'fci'; 'fcimax'; 'rfci'; 'gfci'; 'm3hc';'full'; 'empty'};
    CatMagAlgs={'fci'; 'fcimax'; 'rfci'; 'gfci';'full'; 'empty'};
    MixMagAlgs={'fci'; 'fcimax'; 'rfci'; 'gfci';'full'; 'empty'};
    
    if isnan(algIn)
        algOut='none';
    elseif isnumeric(algIn)
        switch graphType
            case 'ConDag'
                algOut=ConDagAlgs{algIn};   
            case 'CatDag'
                algOut=CatDagAlgs{algIn}; 
            case 'MixDag'
                algOut=MixDagAlgs{algIn}; 
            case 'ConMag'
                algOut=ConMagAlgs{algIn}; 
            case 'CatMag'
                algOut=CatMagAlgs{algIn};
            case 'MixMag'
                algOut=MixMagAlgs{algIn};
            otherwise
                fprintf("\n problem with causalm");
        end
        
    elseif ischar(algIn)
        switch graphType
            case 'ConDag'
                algOut=find(strcmp(ConDagAlgs, algIn));   
            case 'CatDag'
                algOut=find(strcmp(CatDagAlgs, algIn)); 
            case 'MixDag'
                algOut=find(strcmp(MixDagAlgs, algIn)); 
            case 'ConMag'
                algOut=find(strcmp(ConMagAlgs, algIn)); 
            case 'CatMag'
                algOut=find(strcmp(CatMagAlgs, algIn));
            case 'MixMag'
                algOut=find(strcmp(MixMagAlgs, algIn));
            otherwise
                fprintf("\n problem with causalm");
        end
    end
    
end
