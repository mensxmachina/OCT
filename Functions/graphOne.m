function oneGraph=graphOne(myGraph)

    Nnodes=size(myGraph,1);
    oneGraph=zeros(Nnodes,Nnodes);
    for i=1:Nnodes
        for j=i+1:Nnodes
            if myGraph(i,j)==2 && myGraph(j,i)==3
                oneGraph(i,j)=1;
                oneGraph(j,i)=0;
                
            elseif myGraph(j,i)==2 && myGraph(i,j)==3
                oneGraph(j,i)=1;
                oneGraph(i,j)=0;
                
            elseif myGraph(i,j)==1 && myGraph(j,i)==1
                oneGraph(i,j)=1;
                oneGraph(j,i)=1; 
            end
        end
    end

end
