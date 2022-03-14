function BICscore=BicAicScore(dag, data, dataType, Ndomain, penDiscount)

    import edu.cmu.tetrad.*
    import java.util.*
    import java.lang.*
    import edu.cmu.tetrad.data.*
    import edu.cmu.tetrad.search.*
    import edu.cmu.tetrad.graph.*  

    %Tetrad:
    %   SCORE=2L-penDiscount*ln(n)*k
    %       if penDiscount=1 : BIC
    %       if penDiscount=2/ln(n) : AIC
    
    Nnodes=size(dag,2);

    if strcmp(dataType, 'continuous')
        list = LinkedList();
        for i=1:Nnodes
            myvar = ContinuousVariable(['X' num2str(i)]);
            list.add(myvar);
        end
        ds2 = VerticalDoubleDataBox(data');
        ds = BoxDataSet(ds2, list);

        Bic=SemBicScore(ds);
        Bic.setPenaltyDiscount(penDiscount);
        
    elseif strcmp(dataType,'categorical')
        list = LinkedList();
        for i=1:Nnodes
            var = DiscreteVariable(['X' num2str(i)], Ndomain(i));
            list.add(var);
        end
        ds2 = VerticalIntDataBox(data');
        ds = BoxDataSet(ds2, list);
    
        Bic=BicScore(ds);
        Bic.setPenaltyDiscount(penDiscount);
    end
    
    %Local Scores
    LocalSc=zeros(Nnodes,1);
    for node=1:Nnodes
        Pa=find(dag(:,node)==1);
        %fprintf("\nNode:%d, Pa:%s", node, sprintf("%d ", Pa));
        if isempty(Pa)
            LocalSc(node,1)=Bic.localScore(node-1);
        else
            LocalSc(node,1)=Bic.localScore(node-1,Pa-1);
        end 
    end
    BICscore=sum(LocalSc);

end
