function isCat=isCategorical(vec)

    %check which columns have categorical values
    Ncol=size(vec,2);
    isCat=false(1,Ncol);
    for i=1:Ncol
        if (floor(vec(1,i))==vec(1,i))
            isCat(1,i)=true;
        end
    end
    
end
