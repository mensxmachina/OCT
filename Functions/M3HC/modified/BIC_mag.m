function Score = BIC_mag(mag, dataset, tol)
%Compute BIC score
%Function from M3HC package

    nVars=size(mag,1) ;
    nEdges=nnz(mag)/2;
    nSamples=size(dataset.data,1);
    isLatent=dataset.isLatent;
    
    covMat = cov(dataset.data(:, ~isLatent));
    
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

