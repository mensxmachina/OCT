function M=multiAUC(labels, estProbs, classes)

    %based on HandTill2001 package
    
    C=size(estProbs,2);
    pairs = nchoosek(classes,2);
    Npairs=size(pairs,1);
    Aij=zeros(Npairs,1);
    for p=1:Npairs
        i=pairs(p,1);
        j=pairs(p,2);
        %fprintf("\n pair %d-%d", i, j);
        
        idxSamples=find(labels==i | labels==j);
        
        t=i;
        [~,~,~,aij] = perfcurve(labels(idxSamples),estProbs(idxSamples,classes==t),t);
        %fprintf("\n\t Pos:%d  auc:%0.2f", t, aij);
        
        t=j;
        [~,~,~,aji] = perfcurve(labels(idxSamples),estProbs(idxSamples,classes==t),t);
        %fprintf("\n\t Pos:%d  auc:%0.2f", t, aji);
        
        Aij(p,1)=(aij + aji)/2;
    end
    M=(2/(C*(C-1)))*sum(Aij);

end
