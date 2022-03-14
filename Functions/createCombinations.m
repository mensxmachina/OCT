function Configs=createCombinations(cdParam, graphType)

    flag=10000;

    algs=cdParam.algs;
    indTests=cdParam.indTests;
    scores=cdParam.scores;
    alpha=cdParam.alpha;
    penaltyDiscount=cdParam.penaltyDiscount;
    structurePrior=cdParam.structurePrior;

    if size(alpha,1)>1
        alpha=alpha';
    end
    if size(penaltyDiscount,1)>1
        penaltyDiscount=penaltyDiscount';
    end
    if size(structurePrior,1)>1
        structurePrior=structurePrior';
    end


    numAlgs=[];
    numTests=[];
    numScores=[];
    for i=1:length(algs)
        curNum=algMap(algs{i}, graphType);
        if ~isempty(curNum)
            numAlgs=[numAlgs,curNum];
        end
    end
    for i=1:length(indTests)
        curTest=indTestMap(indTests{i}, graphType);
        if ~isempty(curTest)
            numTests=[numTests,curTest];
        end
    end
    for i=1:length(scores)
        curScore=scoreMap(scores{i}, graphType);
        if ~isempty(curScore)
            numScores=[numScores,curScore];
        end
    end

    if isempty(numAlgs)
        numAlgs=flag;
    end
    if isempty(numTests)
        numTests=flag;
    end
    if isempty(numScores)
        numScores=flag;
    end

    Comb=combvec(numAlgs,  numTests, alpha, numScores, penaltyDiscount, structurePrior);
    Comb=Comb';

    NumLingam=algMap('lingam', graphType);
    Lingam=ismember(Comb(:,1),NumLingam);

    NumMmhc=algMap('mmhc', graphType);
    Mmhc=ismember(Comb(:,1),NumMmhc);

    NumM3hc=algMap('m3hc', graphType);
    m3hc=ismember(Comb(:,1),NumM3hc);

    NumFges=algMap('fges', graphType);
    Fges=ismember(Comb(:,1),NumFges);

    NumBDeu=scoreMap('bdeu', graphType);
    BDeu=ismember(Comb(:,4),NumBDeu);

    %constraint
    NumPc=algMap('pc', graphType);
    NumCpc=algMap('cpc', graphType);
    NumPcstable=algMap('pcstable', graphType);
    NumCpcstable=algMap('cpcstable', graphType);
    NumFci=algMap('fci', graphType);
    NumFcimax=algMap('fcimax', graphType);
    NumRfci=algMap('rfci', graphType);

    Constraint=(ismember(Comb(:,1),NumPc) |...
                ismember(Comb(:,1),NumCpc)| ...
                ismember(Comb(:,1),NumPcstable) |...
                ismember(Comb(:,1),NumCpcstable) | ...
                ismember(Comb(:,1),NumFci) |...
                ismember(Comb(:,1),NumFcimax) | ...
                ismember(Comb(:,1),NumRfci));


    NumFull=algMap('full', graphType);
    Full=ismember(Comb(:,1),NumFull);

    NumEmpty=algMap('empty', graphType);
    Empty=ismember(Comb(:,1),NumEmpty);

    %numAlgs, numTests, alpha, numScores, penaltyDiscount, structurePrior
    Comb(Lingam, 2:end)=flag;        
    Comb(Mmhc, 2)=flag; 
    Comb(Mmhc, 4:end)=flag; 
    Comb(m3hc, 2)=flag; 
    Comb(m3hc, 4:end)=flag;   
    Comb(Fges, 2:3)=flag;      
    Comb(Constraint, 4:end)=flag;
    Comb(Full, 2:end)=flag;
    Comb(Empty, 2:end)=flag;
    Comb(BDeu, 5)=flag;
    NoAlg=ismember(Comb(:,1), flag);

    isIndTestFlag=ismember(Comb(:,2), flag);
    ConstraintNotest=(Constraint & isIndTestFlag);

    isScoreFlag=ismember(Comb(:,4), flag);
    FgesNoScore=(Fges & isScoreFlag);

    toDelete=(ConstraintNotest | FgesNoScore |NoAlg);
    Comb(toDelete,:)=[];

    Comb = unique(Comb,'rows', 'stable');

    Comb(Comb==flag)=nan;

    %numAlgs, numTests, alpha, numScores, penaltyDiscount, structurePrior
    Nconfigs=size(Comb,1);
    AlgNames=cell(Nconfigs,1);
    IndTests=cell(Nconfigs,1);
    Scores=cell(Nconfigs,1);
    for c=1:Nconfigs
        AlgNames{c,1}=algMap(Comb(c,1), graphType);
        IndTests{c,1}=indTestMap(Comb(c,2), graphType);
        Scores{c,1}=scoreMap(Comb(c,4), graphType);
    end

    Configs=table(AlgNames, IndTests, Scores, Comb(:,3), Comb(:,5), Comb(:,6));
    Configs.Properties.VariableNames = {'alg','indTest', 'score', 'alpha', 'penaltyDiscount', 'structurePrior' };

end
