function matrix=tetradToMatrix(tGraph)

    import edu.cmu.tetrad.*
    import java.util.*
    import java.lang.*
    import edu.cmu.tetrad.data.*
    import edu.cmu.tetrad.search.*
    import edu.cmu.tetrad.graph.* 

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


            %dag/pdag
            if isempty(iToj) && isempty(jToi)
                matrix(i,j)=0;
                matrix(j,i)=0;
            elseif strcmp(iToj, 'Arrow') && strcmp(jToi, 'Tail')
                matrix(i,j)=1;
                matrix(j,i)=0; 
            elseif strcmp(iToj, 'Tail') && strcmp(jToi, 'Arrow')
                matrix(i,j)=0;
                matrix(j,i)=1;
            elseif strcmp(iToj, 'Tail') && strcmp(jToi, 'Tail')
                matrix(i,j)=1;
                matrix(j,i)=1;
            elseif strcmp(iToj, 'Circle') && strcmp(jToi, 'Circle')
                matrix(i,j)=1;
                matrix(j,i)=1;
            elseif strcmp(iToj, 'Arrow') && strcmp(jToi, 'Arrow')
                matrix(i,j)=1;
                matrix(j,i)=1;
            else
                fprintf("\nproblem tetradToMatrix");

            end

        end
    end

end
