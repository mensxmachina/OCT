function [resimData, dataInfo] = resimulate_data(realData, simParam, isCat)

    Nnodes=size(realData,2);
    Pas=simParam.Pas;
    bestModels=simParam.bestModels;
    Residuals=simParam.Residuals;
    Nsamples=simParam.Nsamples;

    %topo order (striant)
    edges=0;
    for i=1:Nnodes
        edges=edges+length(Pas{i,1});
    end
    topograph=spalloc(Nnodes,Nnodes,edges);
    for i=1:Nnodes
        topograph(Pas{i,1},i) = 1;
    end
    order=graphtopoorder(sparse(topograph));


    %Resimulation
    resimData=zeros(Nsamples, Nnodes);
    fprintf("\nResimulate");
    for node=order
        curPa=Pas{node};
        bestM=bestModels{node,1};

        if isempty(curPa)
            resimData(:, node)=randsample(realData(:, node), Nsamples, true);
        else 
            for i=1:Nsamples                  
                if isCat(node)
                    if strcmp(bestModels{node,2}, 'svm')
                        [~,~,~,curCpt] = predict(bestM, resimData(i, curPa));
                    elseif strcmp(bestModels{node,2}, 'rf')
                        [~,curCpt] = predict(bestM, resimData(i, curPa));
                    end

                    cumprobs = cumsum(curCpt);
                    value = [];
                    while isempty(value)
                        value = find(cumprobs - rand > 0, 1 );
                    end        
                    resimData(i, node)=value-1;  

                else 
                    j=randi(size(realData,1));  
                    pred=bestM.predict(resimData(i, curPa));
                    resimData(i, node)=pred+Residuals(j,node); 
                end
            end
        end   
    end


    Classes=cell(1,Nnodes);
    Ndomain=zeros(1,Nnodes);
    for node=1:Nnodes
        if isCat(node)
            Classes{1,node}=unique(resimData(:,node))';
            Ndomain(1,node)=max(Classes{1,node})+1; %[0,1,...,maxC]
        end
    end
    dataInfo.Classes=Classes;
    dataInfo.Ndomain=Ndomain;
    dataInfo.isCat=isCat;

end
