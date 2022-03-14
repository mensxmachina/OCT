function [AP, AR,  AHP, AHR]=ApArAhpAhr(truePdag, estPdag)

    trueG=convert(truePdag);
    estG=convert(estPdag);
    
    %Adjacency 
    nnzIndEst=find(triu(estG));
    nnzIndTrue=find(triu(trueG));
    SameInd=ismember(nnzIndEst, nnzIndTrue);
    NcorrectEdges=nnz(SameInd);
    NestEdges=length(nnzIndEst);
    NtrueEdges=length(nnzIndTrue);
    AP=NcorrectEdges/NestEdges;
    AR=NcorrectEdges/NtrueEdges;


    %Orientation
    UnorientEst=find(triu(estG)==1);
    UnorientTrue=find(triu(trueG)==1);

    OrientEst=find(estG==2);
    OrientTrue=find(trueG==2);

    SameIndUnorient=ismember(UnorientEst, UnorientTrue);
    NcorrectUnorient=nnz(SameIndUnorient);

    SameIndOrient=ismember(OrientEst, OrientTrue);
    NcorrectOrient=nnz(SameIndOrient);

    NcorrentEdgesOrient=NcorrectUnorient+NcorrectOrient;
    AHP=NcorrentEdgesOrient/NestEdges;
    AHR=NcorrentEdgesOrient/NtrueEdges;

end

function Gnew=convert(G)
    Nnodes=size(G,2);
    Gnew=G;
    for i=1:Nnodes
        for j=i+1:Nnodes
            if G(i,j)==1 && G(j,i)==0
                Gnew(i,j)=2;
                Gnew(j,i)=3;
            end
            if G(j,i)==1 && G(i,j)==0
                Gnew(j,i)=2;
                Gnew(i,j)=3;
            end

        end
    end
end
