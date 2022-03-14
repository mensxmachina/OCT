function data=simulateContinuous(nodes, simParam)

    Nsamples=simParam.Nsamples;
    errorDist=simParam.errorDist;
    errorU=simParam.errorU;
    func=simParam.func;
    Nnodes=length(nodes);

    edges=0;
     for i=1:Nnodes
        headers{i} = nodes{i}.name;
        edges=edges+length(nodes{i}.parents);
    end
    graph=spalloc(Nnodes,Nnodes,edges);
    for i=1:Nnodes
        graph(nodes{i}.parents,i) = 1;
    end
    ord=graphtopoorder(sparse(graph));



    data=nan(Nsamples, Nnodes);
    for node=ord    
        curnode=nodes{node};
        curPa=curnode.parents;
        curb=curnode.beta;
        curmi=curnode.mi;
        curs=curnode.s;

        if strcmp(errorDist, 'gaussian')
            error=normrnd(curmi,curs, Nsamples,1);
        elseif strcmp(errorDist,'uniform')
            error=unifrnd(errorU(1),errorU(2), Nsamples,1);
        end


        if isempty(curPa)
            if strcmp(func, 'tanh')
                y=tanh(error);
            else
                y=error; 
            end
        else 
            inst=data(:, curPa);

            if strcmp(func, 'sumX')
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'sumX2')
                inst=inst.^2;
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'sumX3')
                inst=inst.^3;
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'sumX-1')
                inst=inst.^(-1);
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'prodX')
                y=prod((curb.*inst),2)+error;

            elseif strcmp(func, 'tanh')
                y=tanh(sum((curb.*inst),2)+error);

            elseif strcmp(func, 'sumabsX')
                inst=abs(inst);
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'logX')
                inst=log(abs(inst));
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'exp05')
                sgn=sign(inst);
                inst=(abs(inst)).^0.5;
                inst=sgn.*inst;
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'exp15')
                sgn=sign(inst);
                inst=(abs(inst)).^1.5;
                inst=sgn.*inst;
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'logcosh')
                inst=log(cosh(inst));
                y=sum((curb.*inst),2)+error;

            elseif strcmp(func, 'prode')
                y=prod((curb.*inst),2).*error;
            end      
        end

        data(:,node)=y;    
    end

end
