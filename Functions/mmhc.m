function [pdag, dag]=mmhc(data,Ndomain, alpha)

    opt.threshold = alpha;
    opt.epc = 5;
    opt.maxK = 10;
    opt.use_card_lim = 0;
    opt.max_card = 0;
    [a_MMHC,~,~,~,~] = Causal_Explorer('MMHC',data,Ndomain,'MMHC',opt,10,'BDeu');
    dag= full(a_MMHC);

    pdag=dag2cpdag(dag,false);
    pdag=graphOne(pdag);

end
