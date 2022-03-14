function [Probs, maxProbC]=empiricalProb(vec)

    %vec contains categories from 0 to maxC
    %some categories can be missing
    
    A=accumarray(vec+1,1);
    Probs=A./length(vec);
    
    [~, idxmax]=max(Probs);
    maxProbC=idxmax-1;

end
