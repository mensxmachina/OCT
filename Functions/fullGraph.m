function [MecG,G]=fullGraph(Nnodes, causalGraph)

    if strcmp(causalGraph, 'DAG')
        dag=ones(Nnodes, Nnodes);
        dag(1:Nnodes+1:end)=0;
        dag=triu(dag);
        pdag=dag2cpdag(dag, false);

        MecG=pdag;
        G=dag;

    elseif strcmp(causalGraph, 'MAG')
        a=ones(Nnodes, Nnodes);
        au=triu(a)*2;
        al=tril(a)*3;
        Mag=au+al;
        Mag(1:Nnodes+1:end)=0;
        Pag=mag2pag(Mag);

        MecG=Pag;
        G=Mag;
    end

end
