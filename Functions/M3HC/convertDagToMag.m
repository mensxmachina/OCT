function Mag = convertDagToMag(Dag, L, S)

% Find adjacencies
[Mag, Dag] = removeNodes(Dag, [L S]);
S_len = length(S);
L_len = length(L);
nnodes = length(Dag);

S = nnodes-S_len+1:nnodes;
L = nnodes-S_len-L_len+1:nnodes-S_len;
Mag = Mag + Mag';

nnodes = length(Mag);

closure = transitiveClosureSparse_mex(sparse(Dag));

for i = 1:nnodes
    for j = i+1:nnodes
        if(Mag(i,j) == 0 && hasInducingPath(i,j,Dag,L,S,closure))
            Mag(i,j) = 1;
            Mag(j,i) = 1;
        end
    end
end

% Find orientations
for i = 1:nnodes
    for j = i+1:nnodes
        if(Mag(i,j))
            d1 = any(closure(i,[j S]));
            d2 = any(closure(j,[i S]));
            if(d1 && ~d2)
                Mag(i,j) = 2;
                Mag(j,i) = 3;
            elseif(~d1 && d2)
                Mag(i,j) = 3;
                Mag(j,i) = 2;
            elseif(~d1 && ~d2)
                Mag(i,j) = 2;
                Mag(j,i) = 2;
            else
                Mag(i,j) = 3;
                Mag(j,i) = 3;
            end
        end
    end
end

end

function [graph_, graph] = removeNodes(graph, L)
nodes = setdiff(1:length(graph),L);
graph_ = graph(nodes,nodes);

ordering = zeros(length(graph),1);
ctr_b = 1;
ctr_e = length(graph);
L_bin = zeros(length(graph),1);
L_bin(L) = 1;
for i = 1:length(graph)
    if(L_bin(i))
        ordering(ctr_e) = i;
        ctr_e = ctr_e - 1;
    else
        ordering(ctr_b) = i;
        ctr_b = ctr_b + 1;
    end
end
graph = graph(ordering,ordering);
end
