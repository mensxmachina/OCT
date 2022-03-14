function [DSHD, DSIDu, DSIDl,DAP, DAR, infoCols]=distanceOracle...
    (SHD, SIDu, SIDl, AP, AR, cOct, cScores, cStars, cRnd, namesOct, namesScores)

    infoCols=[namesOct, namesScores, {'StARS'}, {'Rnd'}, {'Worst'}];

    %SHD
    DSHDoct=SHD(cOct,1)'-min(SHD);
    DSHDscore=SHD(cScores,1)'-min(SHD);
    DSHDstars=SHD(cStars,1)-min(SHD);
    DSHDrnd=SHD(cRnd,1)-min(SHD);
    DSHDworst=max(SHD)-min(SHD);

    DSHD=[DSHDoct, DSHDscore, DSHDstars, DSHDrnd, DSHDworst];

    %AP
    DAPoct=max(AP)-AP(cOct,1)';
    DAPscore=max(AP)-AP(cScores,1)';
    DAPstars=max(AP)-AP(cStars,1);
    DAPrnd=max(AP)-AP(cRnd,1);
    DAPworst=max(AP)-min(AP);

    DAP=[DAPoct, DAPscore, DAPstars, DAPrnd, DAPworst];

    %AR
    DARoct=max(AR)-AR(cOct,1)';
    DARscore=max(AR)-AR(cScores,1)';
    DARstars=max(AR)-AR(cStars,1);
    DARrnd=max(AR)-AR(cRnd,1);
    DARworst=max(AR)-min(AR);

    DAR=[DARoct, DARscore, DARstars, DARrnd, DARworst];

    %SID
    if ~isnan(SIDu)
        DSIDuoct=SIDu(cOct,1)'-min(SIDu);
        DSIDuscore=SIDu(cScores,1)'-min(SIDu);
        DSIDustars=SIDu(cStars,1)-min(SIDu);
        DSIDurnd=SIDu(cRnd,1)-min(SIDu);
        DSIDuworst=max(SIDu)-min(SIDu);

        DSIDu=[DSIDuoct, DSIDuscore, DSIDustars, DSIDurnd, DSIDuworst];

        DSIDloct=SIDl(cOct,1)'-min(SIDl);
        DSIDlscore=SIDl(cScores,1)'-min(SIDl);
        DSIDlstars=SIDl(cStars,1)-min(SIDl);
        DSIDlrnd=SIDl(cRnd,1)-min(SIDl);
        DSIDlworst=max(SIDl)-min(SIDl);

        DSIDl=[DSIDloct, DSIDlscore, DSIDlstars, DSIDlrnd, DSIDlworst];

    else
        DSIDu=nan;
        DSIDl=nan;
    end

end
