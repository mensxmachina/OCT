function ds=tetradData(data, dataInfo, graphInfo)

    import edu.cmu.tetrad.*
    import java.util.*
    import java.lang.*
    import edu.cmu.tetrad.data.*
    import edu.cmu.tetrad.search.*
    import edu.cmu.tetrad.graph.*   
    import edu.cmu.tetrad.search.SearchGraphUtils.*
    import edu.cmu.tetrad.algcomparison.score.*
    import edu.cmu.tetrad.algcomparison.independence.*
    import edu.cmu.tetrad.util.*

    Ndomain=dataInfo.Ndomain;
    isCat=dataInfo.isCat;
    graphType=graphInfo.graphType;

    switch graphType
        case 'ConDag'
            [~, Nnodes]=size(data);
            list = LinkedList();
            for i=1:Nnodes
                var = ContinuousVariable(['X' num2str(i)]);
                list.add(var);
            end
            ds2 =VerticalDoubleDataBox(data');
            ds = BoxDataSet(ds2, list);

        case 'CatDag'
            [~, Nnodes]=size(data);
            list = LinkedList();
            for i=1:Nnodes
                var = DiscreteVariable(['X' num2str(i)], Ndomain(i));
                list.add(var);
            end
            ds2 = VerticalIntDataBox(data');
            ds = BoxDataSet(ds2, list);

        case 'MixDag'
            isContinuous=~isCat;
            [Nsamples, Nnodes]=size(data);
            dataC=data(:, isContinuous);
            dataD=data(:, ~isContinuous);
            list = LinkedList();
            for i=1:Nnodes
                if isContinuous(i)
                    var =ContinuousVariable(['X' num2str(i)]);
                else
                    var = DiscreteVariable(['X' num2str(i)], Ndomain(i));
                end
                list.add(var);
            end
            dsM = MixedDataBox(list, Nsamples);
            if any(isContinuous)
                dsC = VerticalDoubleDataBox(dataC');
            end
            if any(isCat)
                dsD = VerticalIntDataBox(dataD');
            end
            for i=0:(Nsamples-1)
                d=0;
                c=0;
                for node=0:(Nnodes-1)
                    if isContinuous(node+1)
                        dsM.set(i,node, dsC.get(i,c));
                        c=c+1;
                    else
                        dsM.set(i,node, dsD.get(i,d));
                        d=d+1;
                    end
                end
            end
            ds = BoxDataSet(dsM, list);


        case 'ConMag'
            obsNnodes=size(data,2);
            list = LinkedList();
            for i=1:obsNnodes
                var = ContinuousVariable(['X' num2str(i)]);
                list.add(var);
            end
            ds2 = VerticalDoubleDataBox(data');
            ds = BoxDataSet(ds2, list);

        case 'CatMag'
            ObsNodes=size(data,2);    
            list = LinkedList();
            for i=1:ObsNodes
                var = DiscreteVariable(['X' num2str(i)], Ndomain(i));
                list.add(var);
            end
            ds2 = VerticalIntDataBox(data');
            ds = BoxDataSet(ds2, list);

        case 'MixMag'
            [Nsamples, ObsNodes]=size(data);
            isCon=~isCat;
            obsdataC=data(:, isCon);
            obsdataD=data(:, ~isCon);
            list = LinkedList();
            for i=1:ObsNodes
                if isCon(i)
                    var =ContinuousVariable(['X' num2str(i)]);
                else
                    var = DiscreteVariable(['X' num2str(i)], Ndomain(i));
                end
                list.add(var);
            end

            dsM = MixedDataBox(list, Nsamples);
            if any(isCon)
                dsC = VerticalDoubleDataBox(obsdataC');
            end
            if any(isCat)
                dsD = VerticalIntDataBox(obsdataD');
            end

            for i=0:(Nsamples-1)
                d=0;
                c=0;
                for node=0:(ObsNodes-1)
                    if isCon(node+1)
                        dsM.set(i,node, dsC.get(i,c));
                        c=c+1;
                    else
                        dsM.set(i,node, dsD.get(i,d));
                        d=d+1;
                    end
                end
            end
            ds = BoxDataSet(dsM, list);
    end

end
