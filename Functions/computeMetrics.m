function [SHD, SIDu, SIDl, AP, AR]=computeMetrics (trueMec, trueG, allMecG, causalGraph, computeSid)

    %SHD, SID, AP, AR
    Nconfigs=length(allMecG);
    SHD=nan(Nconfigs,1); 
    SIDu=nan(Nconfigs,1);
    SIDl=nan(Nconfigs,1);
    AP=nan(Nconfigs,1);
    AR=nan(Nconfigs,1);

    for c=1:Nconfigs
        curMec=allMecG{c,1};     

        if strcmp(causalGraph, 'DAG')
            SHD(c,1)=StructHammingDist(trueMec, curMec);  
            if computeSid
                [SIDu(c,1), SIDl(c,1)] = StructInterventionalDist(trueG, curMec);
            end
            [AP(c,1), AR(c,1),~, ~]=ApArAhpAhr(trueMec, curMec);

        else
            SHD(c,1)= structuralHammingDistancePAG(curMec,trueMec);
            [AP(c,1), AR(c,1)]=ApAr_MAG(trueMec, curMec);
        end
    end

end
