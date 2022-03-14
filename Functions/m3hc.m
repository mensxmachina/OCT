function [Pag, Mag]=m3hc(data, alpha)

    obsNnodes=size(data,2);
    maxCondSet=obsNnodes;
    tol=10e-3;
    cor=false;
    tabu=true;
    TABUsize=100;
    skeleton='MMPC';

    [Mag, ~, ~, ~, ~, ~] = MMMHCsim(data, maxCondSet,alpha,tol,cor,tabu,TABUsize,skeleton);

    Pag=mag2pag(Mag);

end
            