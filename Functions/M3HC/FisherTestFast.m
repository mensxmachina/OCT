% X: index of variable X in data
% Y: index of variable Y in data
% Z: vector of indices of conditioning variables in data
% data: NxM matrix with N samples and M variables
% testParams: struct with field 'domainCounts' containing a vector of size M with the number of possible values for each variable
% for example, a variable taking values 0,1,2 at index i will have testParams.domainCounts(i) = 3
function [pvalue, statistic]= FisherTestFast(X, Y, Z, data, testParams)

if isempty(Z)
    pcorr = data(X,Y);
else
    corrMatrix = data([X Y Z],[X Y Z]);
    residCorrMatrix = corrMatrix(1:2, 1:2) - corrMatrix(1:2, 3:end)*(corrMatrix(3:end, 3:end)\corrMatrix(3:end, 1:2));
    pcorr = (-residCorrMatrix(1,2) / sqrt(residCorrMatrix(1,1) * residCorrMatrix(2,2)));
end

df = testParams.N - length(Z) - 3;
statistic = -abs(sqrt(df) * 0.5*log((1+pcorr)/(1-pcorr)));
% pvalue = 2 * tcdf(statistic, df); % For small sample sizes (<100?)
% pvalue = 2 * normcdf(statistic)
pvalue = erfc(-statistic ./ sqrt(2)); % For large sample sizes (>= 100?)
end