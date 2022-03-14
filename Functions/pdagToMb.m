function MBs =  pdagToMb (pdag)

    Nnodes = size(pdag,1);
    MBs=cell(Nnodes,1);
    
    for i=1:Nnodes 
        adjToi=find(pdag(:,i)==1);
        adjFromi=find(pdag(i,:)==1)';
        undirected=intersect(adjToi, adjFromi);
        parents=setdiff(adjToi, undirected);
        children=setdiff(adjFromi, undirected);

        spouses=[];
        for j=1:length(children)
            adjToj=find(pdag(:,children(j))==1);
            adjFromj=find(pdag(children(j),:)==1)';
            undirectedj=intersect(adjToj, adjFromj);
            parentsj=setdiff(adjToj, undirectedj);

            if isempty(parentsj)
                continue
            else
                spouses=cat(1,spouses, parentsj);
            end
        end

        spouses(spouses==i)=[];
        MBs{i,1}=unique([undirected; parents; children; spouses]);
    end

end
