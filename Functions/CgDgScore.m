function ScoreValue=CgDgScore(dag,data, isCat, Ndomain, name,ScoreParams)

    import edu.cmu.tetrad.*
    import java.util.*
    import java.lang.*
    import edu.cmu.tetrad.data.*
    import edu.cmu.tetrad.search.*
    import edu.cmu.tetrad.graph.*
    import edu.cmu.tetrad.*
    import edu.cmu.tetrad.algcomparison.*
    import edu.pitt.csb.*

    [Nsamples, Nnodes]=size(data);
    dataC=data(:, ~isCat);
    dataD=data(:, isCat);
    isContinuous=~isCat;
    
    list = LinkedList();
    for i=1:Nnodes
        if isContinuous(i)
            var = javaObject('edu.cmu.tetrad.data.ContinuousVariable',['X' num2str(i)]);
        else
            var = javaObject('edu.cmu.tetrad.data.DiscreteVariable',['X' num2str(i)], Ndomain(i));
        end
        list.add(var);
    end

    dsM = javaObject('edu.cmu.tetrad.data.MixedDataBox',list, Nsamples);
    if any(isContinuous)
        dsC = javaObject('edu.cmu.tetrad.data.VerticalDoubleDataBox',dataC');
    end
    if any(isCat)
        dsD = javaObject('edu.cmu.tetrad.data.VerticalIntDataBox',dataD');
    end

    for i=0:(Nsamples-1)
        d=0;
        c=0;
        for node=0:(Nnodes-1)
            if isContinuous(node+1)
                dsM.set(i,node, dsC.get(i,c));
                c=c+1;
            else
                dsM.set(i,node, dsD.get(i,d));
                d=d+1;
            end
        end
    end
    ds = BoxDataSet(dsM, list);

    
    if strcmp(name, 'cg-bic')
        Score=ConditionalGaussianScore...
          (ds, ScoreParams.penaltyDiscount, ScoreParams.structurePrior, ScoreParams.discretize); 
    elseif strcmp(name, 'dg-bic')              
        Score=DegenerateGaussianScore(ds);
        Score.setPenaltyDiscount(ScoreParams.penaltyDiscount);
        Score.setStructurePrior(ScoreParams.structurePrior);
    end
    
    %Local Scores
    LocalSc=zeros(Nnodes,1);
    for node=1:Nnodes
        Pa=find(dag(:,node)==1);
        %fprintf("\nNode:%d, Pa:%s", node, sprintf("%d ", Pa));
        if isempty(Pa)
            LocalSc(node,1)=Score.localScore(node-1);
        else
            LocalSc(node,1)=Score.localScore(node-1,Pa-1);
        end
    end
    ScoreValue=sum(LocalSc);

end
