function [AP, AR]=ApAr_MAG(truePag, estPag)

    trueG=truePag;
    estG=estPag;
    
    %Adjacency
    nnzIndEst=find(triu(estG));
    nnzIndTrue=find(triu(trueG));
    SameInd=ismember(nnzIndEst, nnzIndTrue);
    NcorrectEdges=nnz(SameInd);
    NestEdges=length(nnzIndEst);
    NtrueEdges=length(nnzIndTrue);
    AP=NcorrectEdges/NestEdges;
    AR=NcorrectEdges/NtrueEdges;
    
end
