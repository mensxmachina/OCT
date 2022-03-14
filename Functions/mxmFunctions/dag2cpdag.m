function cpdag=dag2cpdag(dag,verbose)

%1. same skeleton with dag : cpdag(i,j)=cpdag(j,i)=1
cpdag=dag+dag.';
%2. Find v structures
bi_dag=dag+dag.';
nVars = length(bi_dag);
unshieldedtriples = cell(nVars,1);
unshieldedpairs = zeros(nVars*nVars,2);

for i = 1:nVars
    neighbours= find(bi_dag(i,:));
    nneighbours = length(neighbours);
    curindex = 1;
    %fprintf("\n Node:%d", i);
    %fprintf("\n\t Neighbours: %s", sprintf("%d ", neighbours));
    for n1 = 1:nneighbours
        curn1 = neighbours(n1);
        for n2 = n1+1:nneighbours
            curn2 = neighbours(n2);
            if (bi_dag(curn1,curn2) == 0)
                %fprintf("\nUnshielded! %d-%d-%d", curn1, i, curn2);
                unshieldedpairs(curindex,1) = curn1;
                unshieldedpairs(curindex,2) = curn2;
                curindex = curindex + 1;
            end
        end
    end
    unshieldedtriples{i} = unshieldedpairs(1:curindex-1,:);
end

for c = 1:nVars
    curtriples = unshieldedtriples{c};
    ntriples = size(curtriples,1);
    %fprintf("\n Node: %d", c);
    for t = 1:ntriples
        a = curtriples(t,1);
        b = curtriples(t,2); 
        %fprintf("\n\t\t Triplet: %d-%d-%d", a,c,b);
        if (dag(a,c)==1 & dag(b,c)==1) % If it forms unshielded collider
            if verbose
                fprintf('\tV struct: Orienting %d->%d<-%d\n',a,c,b);
            end
            cpdag(a,c)=2;
            cpdag(b,c)=2;
            cpdag(c,a)=3;
            cpdag(c,b)=3;
        end
    end
end


%3. Perform 3 orientation rules 
%R1: away from collider
%R2: away from cicles
%R3: double triangle
flag=1;
while(flag)
    flag=0;
    [cpdag,flag] = R1(cpdag, flag, verbose);
    [cpdag,flag] = R2(cpdag, flag, verbose);
    [cpdag,flag] = R3(cpdag, flag, verbose);
    
end  


end


function [graph, flag] = R1(graph, flag, verbose)
% away from collider
% If z->y-x and z,x not adjacent ==> z->y->x

[Xs,Ys] = find(graph == 1);
len = length(Xs);
for i = 1:len
    if(graph(Xs(i),Ys(i)) == 1 && any(graph(:,Ys(i)) == 2 & graph(:,Xs(i)) == 0))
        if(verbose)
            fprintf('\tR1: Orienting %d->%d\n',Ys(i),Xs(i));
        end
        graph(Ys(i),Xs(i)) = 2;
        graph(Xs(i),Ys(i)) = 3;
        flag = 1;
    end
end

end

function [graph, flag] = R2(graph, flag, verbose)
% away from cycles
% If x->y->z and x-z ==> x->z

[Xs, Zs] = find(graph == 1);
len = length(Xs);
for i = 1:len
    if(graph(Xs(i),Zs(i)) == 1 && any(graph(Xs(i),:) == 2 & graph(:,Zs(i))' == 2 & (graph(:,Xs(i))' == 3 | graph(Zs(i),:) == 3)))
        if(verbose)
            fprintf('\tR2: Orienting %d->%d\n',Xs(i),Zs(i));
        end
        graph(Xs(i),Zs(i)) = 2;
        graph(Zs(i),Xs(i)) = 3;
        flag = 1;
    end
end

end

function [graph, flag] = R3(graph, flag, verbose)
% double triangle
% If x->y<-z, x-8-z, x,z not adjacent, 8-y ==> 8->y

[Ths, Ys] = find(graph == 1);
nedges = length(Ths);

for i = 1:nedges
    a = find(graph(:,Ths(i)) == 1 & graph(:,Ys(i)) == 2);
    len = length(a);
    f = false;
    for j = 1:len
        for k = j+1:len
            if(graph(a(j),a(k)) == 0 && graph(Ths(i),Ys(i)) == 1)
                if(verbose)
                    fprintf('\tR3: Orienting %d->%d\n',Ths(i),Ys(i));
                end
                graph(Ths(i),Ys(i)) = 2;
                graph(Ys(i),Ths(i)) = 3;
                flag = 1;
                f = true;
                break;
            end
        end
        if(f)
            break;
        end
    end
end

end

