function Score = BICmag(mag, obsData, tol)
%Compute BIC score
%Function from M3HC package
%kbiza : change input dataset 
%old input: Dataset (Dataset.data, Dataset.isLatent) that includes latent
%variables
%new input : obsData that includes only observed variables

    nVars=size(mag,1) ;
    nEdges=nnz(mag)/2;
    nSamples=size(obsData,1);
    
    covMat = cov(obsData);
    
    isParent=false(nVars);
    isParent((mag==2))=true;

    [nComps, sizes, comps, inComponent]= concomp(mag);
    nsf = -nSamples/2;

    scores = zeros(1,nComps);
    for iComp =1:nComps
        [compMag, district] = componentMag(comps{iComp}, nVars, mag, isParent);
        [scores(iComp)] = score_contrib(compMag, comps{iComp}, district, sizes(iComp), covMat,nSamples, tol);
    end

    tmpSll = nsf*sum(scores);
    Score = -2*tmpSll+log(nSamples)*(2*nVars+nEdges);
end

