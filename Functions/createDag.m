function InputDag=createDag(Nnodes,MaxEdges)

    maxParents=round((MaxEdges/Nnodes)*2);
    Number_edges=0;

    if MaxEdges>Nnodes*(Nnodes-1)/2
        error("Error: number of edges");
    end

    c=1;
    while (Number_edges~=MaxEdges)
        InputDag=randomdag(Nnodes,maxParents);
        Number_edges=nnz(InputDag);    

        c=c+1;
        if c>10^6
            error("Error: cannot create the graph");
        end
    end

end
