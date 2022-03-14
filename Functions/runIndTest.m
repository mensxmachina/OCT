function IndTest= runIndTest (indTestName, ds, alpha)

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
    if strcmp(indTestName, 'fisher')
        IndTest= IndTestFisherZ(ds,alpha);

    elseif strcmp(indTestName, 'kci')
        IndTest=Kci(ds,alpha);

    elseif strcmp(indTestName, 'cci')
        TestCci=CciTest;            
        parameters=Parameters; %set default params, gui            
        parameters.set("cciScoreAlpha", alpha);
        parameters.set("basisType", 2);
        parameters.set("kernelMultiplier",1);
        parameters.set("kernelRegressionSampleSize",100);
        parameters.set("kernelType", 2);
        parameters.set("numBasisFunctions",30);
        IndTest=TestCci.getTest(ds, parameters);

    elseif strcmp(indTestName, 'cg_lrt')
        IndTest=IndTestConditionalGaussianLRT(ds, alpha, discretize);

    elseif strcmp(indTestName, 'dg_lrt')
        IndTest=IndTestDegenerateGaussianLRT(ds);
        IndTest.setAlpha(alpha);

    elseif strcmp(indTestName,  'chisquare')
        IndTest= IndTestChiSquare(ds, alpha); 

    elseif strcmp(indTestName,  'gsquare')
        IndTest=IndTestGSquare(ds,alpha);   

    else
        IndTest=[];
    end

end

