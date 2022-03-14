function matrix = tetradToMatrixL(tGraph)

    Nnodes=tGraph.getNumNodes;
    nodes = tGraph.getNodes;
    matrix = zeros(Nnodes,Nnodes);


    for i = 1:Nnodes
        for j=i+1:Nnodes
            iToj=tGraph.getEndpoint(nodes.get(i-1), nodes.get(j-1));
            jToi=tGraph.getEndpoint(nodes.get(j-1), nodes.get(i-1));

            if ~isempty(iToj)
                iToj=iToj.toString.toCharArray';
            else
                iToj=[];
            end
            if ~isempty(jToi)
                jToi=jToi.toString.toCharArray';
            else
                jToi=[];
            end


            %PAG
            if isempty(iToj)
                matrix(i,j)=0;
            elseif strcmp(iToj, 'Circle') 
                matrix(i,j)=1;
            elseif strcmp(iToj, 'Arrow')
                matrix(i,j)=2;
            elseif strcmp(iToj, 'Tail')
                matrix(i,j)=3;
            end

            if isempty(jToi)
                matrix(j,i)=0;
            elseif strcmp(jToi, 'Circle')
                matrix(j,i)=1;
            elseif strcmp(jToi, 'Arrow')
                matrix(j,i)=2;
            elseif strcmp(jToi, 'Tail')
                matrix(j,i)=3;
            end
        end
    end

end
