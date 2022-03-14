function muD=mutualInfoD(y, yhat)

    %unit: nats
    %y and yhat classes: 0 to C

    Nsamples=length(y);

    Ay=accumarray(y+1,1);
    pY=Ay./Nsamples;

    Ayhat=accumarray(yhat+1,1);
    pYhat=Ayhat./Nsamples;

    Hy=-nansum(pY.*log(pY));
    Hyhat=-nansum(pYhat.*log(pYhat));

    subs=[y, yhat];
    subs=subs+1;
    Ajoint=accumarray(subs,1);
    pJoint=Ajoint./Nsamples;

    Hjoint=-nansum(nansum(pJoint.*log(pJoint)));

    muD=Hy+Hyhat-Hjoint;

end
