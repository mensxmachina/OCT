function R2 = R2metric(y, predictions)
    
    SSres = sum((y - predictions).^2);
    SStot = sum((y - mean(y)).^2);
     
    R2 = 1 - (SSres/SStot);
    
end
