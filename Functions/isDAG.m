function isadag=isDAG(parents)

    %topoorder striant
    Nnodes=size(parents,1);
    edges=0;
    for i=1:Nnodes
        edges=edges+length(parents{i,1});
    end
    topograph=spalloc(Nnodes,Nnodes,edges);
    for i=1:Nnodes
        topograph(parents{i,1},i) = 1;
    end
    %view(biograph(sparse(topograph)))
    isadag=graphisdag(sparse(topograph));
    %order=graphtopoorder(sparse(topograph));
        
end
