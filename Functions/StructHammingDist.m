function shd=StructHammingDist(G1, G2)

    %Structural Hamming Distance
    G1new=convert(G1);
    G2new=convert(G2);
    Dif = G1new~=G2new;  
    shd=nnz(Dif)/2;

end

function Gnew=convert(G)
    Nnodes=size(G,2);
    Gnew=G;
    for i=1:Nnodes
        for j=i+1:Nnodes
            if G(i,j)==1 && G(j,i)==0
                Gnew(i,j)=2;
                Gnew(j,i)=3;
            end
            if G(j,i)==1 && G(i,j)==0
                Gnew(j,i)=2;
                Gnew(i,j)=3;
            end
        end
    end
end
