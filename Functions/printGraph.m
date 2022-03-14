function []= printGraph(matrix)

    Nnodes = size(matrix,2);
    fprintf("\n");

    for i = 1:Nnodes
        for j=i+1:Nnodes
            iToj=matrix(i,j);
            jToi=matrix(j,i);

            if iToj==1 && jToi==0
                fprintf('%d %s-%s %d\n', i, '-','>', j);
            elseif iToj==0 && jToi==1
                fprintf('%d %s-%s %d\n', j, '-','>', i);
            elseif iToj==1 && jToi==1
                fprintf('%d %s-%s %d\n', i, '-','-', j); 
            end  
        end
    end

end
