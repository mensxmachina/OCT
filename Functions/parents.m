function [pa, Npa]=parents(dag)

    Nnodes=size(dag,2);
    pa=cell(Nnodes,1);
    Npa=zeros(Nnodes,1);
    for node=1:Nnodes
        pa{node,1}=find(dag(:,node)==1);
        Npa(node,1)=length(pa{node,1});
    end 
    
end
