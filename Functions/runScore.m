function Score=runScore (scoreName, ds, penaltyDiscount, structurePrior)

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

    discretize=true;
    if strcmp(scoreName, 'sembic')
        Score=SemBicScore(ds);
        Score.setPenaltyDiscount(penaltyDiscount);
        Score.setStructurePrior(structurePrior);

    elseif strcmp(scoreName, 'bdeu')
        Score=BDeuScore(ds);
        Score.setStructurePrior(structurePrior);

    elseif strcmp(scoreName, 'discreteBic')
        Score=BicScore(ds);
        Score.setPenaltyDiscount(penaltyDiscount);
        Score.setStructurePrior(structurePrior);

    elseif strcmp(scoreName, 'cg_bic')                
        Score=ConditionalGaussianScore(ds, penaltyDiscount, structurePrior,discretize);

    elseif strcmp(scoreName, 'dg_bic') 
        Score=DegenerateGaussianScore(ds);
        Score.setPenaltyDiscount(penaltyDiscount);
        Score.setStructurePrior(structurePrior);

    elseif strcmp(scoreName, 'cci')
        ScoreCci=CciScore;
        parameters=Parameters; %set default params, gui
        parameters.set("basisType", 2);
        parameters.set("cciScoreAlpha", 0.01);
        parameters.set("kernelMultiplier",1);
        parameters.set("kernelRegressionSampleSize",100);
        parameters.set("kernelType", 2);
        parameters.set("numBasisFunctions",30);
        Score=ScoreCci.getScore(ds, parameters);    

    else
        Score=[];
    end

end
