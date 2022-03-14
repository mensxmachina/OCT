function [MecG, tMecG, G, tG]=tetradAlgs(config,data, dataInfo, graphInfo)

    graphType=graphInfo.graphType;
    scoreName=config.score;
    indTestName=config.indTest;

    ds=tetradData(data, dataInfo, graphInfo);
    Score=runScore(scoreName, ds, config.penaltyDiscount, config.structurePrior);
    IndTest= runIndTest(indTestName, ds, config.alpha);
    Alg = runAlg(config.alg, IndTest, Score);
    [MecG, tMecG, G, tG]= runSearch(Alg, config.alg, ds,graphType);

end
