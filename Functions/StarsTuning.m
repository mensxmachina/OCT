function [cStars, valsStars]=StarsTuning(data, dataInfo,graphInfo, Configs)

    %info
    [Nsamples, Nnodes]=size(data);
    Nconfigs=size(Configs,1);
    Nedges_complete=Nnodes*(Nnodes-1)/2;

    %StARS parameters
    Nsets=20;
    thr=0.05;
    if Nsamples>144
        Nsub=floor(10*sqrt(Nsamples));
    else
        Nsub=floor(0.8*Nsamples);
    end


    fprintf("\nTuning with StARS\n");

    %Causal discovery on each subsample
    Gs=cell(Nsets,1);
    for i=1:Nsets
        subsample=datasample(data, Nsub, 'Replace', false);
        [~, Gs{i,1}, ~,  ~]=causalDiscovery(subsample, dataInfo,graphInfo, Configs);
    end


    %Compute sparsity and instability (Delta) for each configuration
    Sparsity=zeros(Nconfigs, Nsets);
    Delta=zeros(Nconfigs, 1);

    for c=1:Nconfigs   
        Count=zeros(Nnodes,Nnodes);    

        for i=1:Nsets     
            curG=Gs{i,1}{c,1};
            switch graphInfo.causalGraph            
                case 'DAG'
                    %printGraph(curG)  
                    Nedges=nnz(curG);
                case 'MAG'
                    %printedgesmcg(curG);
                    Nedges=nnz(curG)/2;
            end

            Sparsity(c,i)=Nedges;

            for s=1:Nnodes
                for t=s+1:Nnodes
                    if curG(s,t)~=0 || curG(t,s)~=0
                        Count(s,t)=Count(s,t)+1;
                    end
                end  
            end
        end

        theta=Count./Nsets;
        ksi=(1-theta).*theta.*2;
        Delta(c,1)=sum(sum(ksi))/Nedges_complete;
    end


    %Sort Delta based on Sparsity (number of edges in est Graphs)
    avgSparsity=mean(Sparsity,2);
    [~,SortIdx]=sort(avgSparsity);
    SortDelta=Delta(SortIdx);


    %Monotonize SortDelta and select configuration
    maxSortDelta=SortDelta;
    for i=2:length(SortDelta)
        maxSortDelta(i)=max(maxSortDelta(i), maxSortDelta(i-1));
    end
    acceptedIdx=find(maxSortDelta<=thr);
    if ~isempty(acceptedIdx)
        OptIdx=acceptedIdx(end);
    else
        OptIdx=1;
    end
    cStars=SortIdx(OptIdx);

    % fprintf("\n\nSortDelta   :%s", sprintf("%0.3f ", SortDelta));
    % fprintf("\n\nMaxSortDelta:%s", sprintf("%0.3f ", maxSortDelta));

    %Save
    valsStars.sortIdx=SortIdx;
    valsStars.sortDelta=SortDelta;
    valsStars.maxsortDelta=maxSortDelta;
    valsStars.subsampleG=Gs;

end
