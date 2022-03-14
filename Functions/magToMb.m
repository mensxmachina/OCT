function MbX=magToMb(matMag)

    %Finds the Markov blanket of the input MAG.

    nVars=size(matMag,1);
    
    PaX=cell(nVars,1);   %Parents of X
    ChX=cell(nVars,1);   %Children of X
    PaChX=cell(nVars,1); %Parents of Childern of X  
    DiX=cell(nVars,1);    %District set of X
    DiChX=cell(nVars,1);  %Distrct set of Children of X
    PaDiX=cell(nVars,1);  %Parents of nodes in District set of X
    PaDiChX=cell(nVars,1);%Parents of nodes in District set of Children of X

    
    BidirEdges=[];
    for i=1:nVars        
            %Parents
            Pa=find(matMag(i,:)==3);
            %Children
            posCh=find(matMag(i,:)==2);


            Ch=posCh;
            for c=1:length(posCh)
                if (matMag(posCh(c), i)==2)
                    %is not a Child
                    [~,r]=ismember(posCh(c),Ch);
                    Ch(r)=[];
                    %it is a Bidirected edge
                    BidirEdges=cat(1, BidirEdges, [i,posCh(c)]);
                end
            end  

            %Parent of Children
            PaCh=[];
            for c=1:length(Ch)
                curCh=Ch(c);
                curPaCh=find(matMag(curCh,:)==3);
                PaCh=cat(2,PaCh,curPaCh);
            end
            PaCh(PaCh==i)=[];

            PaX{i,1}=Pa;
            ChX{i,1}=Ch;    
            PaChX{i,1}=PaCh;
    end
    BidirEdges=unique(sort(BidirEdges,2), 'rows');

    %Find Districts 
    if ~isempty(BidirEdges)
        NodesBi=unique(BidirEdges);
        nNodesBi=length(NodesBi);
        DistrictSets=cell(nNodesBi,1);
        G=graph(BidirEdges(:,1), BidirEdges(:,2));
        for n=1:length(NodesBi)
            DistrictSets{n} = dfsearch(G,NodesBi(n));
        end



        %District(X): each row contains the District(X)
        for i=1:nVars
            if ~ismember(i, NodesBi)
                DiX{i,1}=[];
            else
                [~,idxBi]=ismember(i, NodesBi);
                DiX{i,1}=DistrictSets{idxBi}';  
                DiX{i,1}(DiX{i,1}==i)=[];
            end
        end

        %District of Children of X
        %DiChXs:  row = X and  cell=district set of its children
        for i=1:nVars
            Nch=length(ChX{i,1});
            DiChX{i,1}=[];
            for c=1:Nch
                curCh=ChX{i,1}(c);              
                DiChX{i,1}=cat(2,DiChX{i,1},DiX{curCh});
            end
            DiChX{i,1}=unique(DiChX{i,1});
        end


        %Parents of Districts of X
        for i=1:nVars
            nDiX=length(DiX{i});
            for d=1:nDiX
                Di=DiX{i}(d);
                PaDi=PaX{Di};
                PaDiX{i,1}=cat(2,PaDiX{i,1},PaDi);
            end
            PaDiX{i,1}=unique(PaDiX{i,1});
        end

        %Parents of Districts of Children of X
        for i=1:nVars
            nDiChX=length(DiChX{i});
            for dch=1:nDiChX
                DiCh=DiChX{i}(dch);
                PaDiCh=PaX{DiCh};
                PaDiChX{i,1}=cat(2,PaDiChX{i,1},PaDiCh);
            end 
            PaDiChX{i,1}=unique(PaDiChX{i,1});
        end   
    end


    %Final MB
    %MbX: PaX, ChX, PaChX, DiX, DiChX, PaDiX, PaDiChX
    MbX=cell(nVars,1);
    for i=1:nVars
        MbX{i,1}=[];
        if ~isempty(PaX{i})
           MbX{i,1}=cat(2,MbX{i,1},PaX{i});
        end
        if ~isempty (ChX{i})
            MbX{i,1}=cat(2,MbX{i,1},ChX{i});
        end
        if ~isempty (PaChX{i})
            MbX{i,1}=cat(2,MbX{i,1},PaChX{i});
        end
        if ~isempty (DiX{i})
            MbX{i,1}=cat(2,MbX{i,1},DiX{i});
        end
        if ~isempty (DiChX{i})
            MbX{i,1}=cat(2,MbX{i,1},DiChX{i});
        end
        if ~isempty (PaDiX{i})
            MbX{i,1}=cat(2,MbX{i,1},PaDiX{i});
        end
        if ~isempty (PaDiChX{i})
            MbX{i,1}=cat(2,MbX{i,1},PaDiChX{i});
        end

        MbX{i,1}=unique(MbX{i,1});
        %Exclude X
        MbX{i,1}(MbX{i,1}==i)=[];

    end
    
end
