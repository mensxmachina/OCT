function muC=mutualInfoC(y, yhat)

    %unit: nats

    if std(y)==0 || std(yhat)==0
        error("MutualInfo: Error with std");
    end

    sy=std(y);
    Hy=(1/2)*log(2*pi*exp(1)*sy^2);

    syhat=std(yhat);
    Hyhat=(1/2)*log(2*pi*exp(1)*syhat^2);


    if y==yhat          
        muC=Hy; 
    else   
        nVars=2;
        K=cov(y,yhat);
        c=(2*pi*exp(1))^nVars;
        Hjoint=(1/2)*log(c*det(K));

        muC=Hy+Hyhat-Hjoint;
    end

end
