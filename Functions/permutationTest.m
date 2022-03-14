function [OCTc, OCTsc, isEqual, pvalues] = permutationTest(isCat, poolYs, poolYhats, poolScores, Classes, Nper, idxs, metricName, Metric, MBsize,octsAlpha)

    [Nconfigs, Nnodes]=size(poolYhats);
    
    isEqual=ones(Nconfigs,1);
    pvalues=ones(Nconfigs,1);
    
    mMB=mean(MBsize,2); %mean over folds
    mMetric=nanmean(Metric,2); %mean over nodes
    if strcmp(metricName, 'mutual') || strcmp(metricName, 'auc') || strcmp(metricName, 'r2')
        [~,bestC]=max(mMetric);
        OCTc=bestC;
    elseif strcmp(metricName, 'rmse')
        [~,bestC]=min(mMetric);
        OCTc=bestC;
    end
    
    %permutation testing
    for c=1:Nconfigs  
        if (c==bestC)
            continue
        end
        swapBestMetric=zeros(Nper,Nnodes);
        swapCurMetric=zeros(Nper,Nnodes);

        for node=1:Nnodes            
            poolYhat_best=poolYhats{bestC, node};
            poolYhat_cur=poolYhats{c, node};
            poolScores_best=poolScores{bestC, node};
            poolScores_cur=poolScores{c, node};
            
            poolY=poolYs{1,node};

            %swap predictions
            for i=1:Nper
                idx=idxs{i,1};

                swapBest=poolYhat_best;
                swapBest(idx)=poolYhat_cur(idx);

                swapCur=poolYhat_cur;
                swapCur(idx)=poolYhat_best(idx);
                              
                if isCat(node)
                    if strcmp(metricName, 'mutual')
                        swapBestMetric(i,node)=mutualInfoD(poolY, swapBest);
                        swapCurMetric(i,node)=mutualInfoD(poolY, swapCur);
                        
                    elseif strcmp(metricName, 'auc')
                        
                        swapBestScores=poolScores_best;
                        swapBestScores(idx,:)=poolScores_cur(idx,:);
                
                        swapCurScores=poolScores_cur;
                        swapCurScores(idx,:)=poolScores_best(idx,:);
                
                        swapBestMetric(i,node)=multiAUC(poolY, swapBestScores, Classes{1,node});
                        swapCurMetric(i,node)=multiAUC(poolY, swapCurScores, Classes{1,node});
                    end  
                    
                else %isContinuous     
                    if strcmp(metricName, 'mutual')
                        swapBestMetric(i,node)=mutualInfoC(poolY, swapBest);
                        swapCurMetric(i,node)=mutualInfoC(poolY, swapCur);
                    elseif strcmp(metricName, 'r2')
                        swapBestMetric(i,node)=R2metric(poolY, swapBest);
                        swapCurMetric(i,node)=R2metric(poolY, swapCur);
                    elseif strcmp(metricName, 'rmse')
                        swapBestMetric(i,node) = sqrt(mean((poolY - swapBest).^2));
                        swapCurMetric(i,node) = sqrt(mean((poolY - swapCur).^2));
                    end
                end               
            end
        end
        
        
        curMetric=mMetric(c);
        
        if strcmp(metricName, 'mutual') || strcmp(metricName, 'auc') || strcmp(metricName, 'r2')
            bestMetric=max(mMetric);
            obsTstat=bestMetric-curMetric;       
            Tstat=mean(swapBestMetric,2)-mean(swapCurMetric,2);  
            
        elseif strcmp(metricName, 'rmse')
            bestMetric=min(mMetric);
            obsTstat=curMetric-bestMetric;       
            Tstat=mean(swapCurMetric,2)-mean(swapBestMetric,2);
        end
        
        pval=nnz(Tstat>=obsTstat)/Nper;
        pvalues(c,1)=pval;

        %H0: the difference in performance is zero
        if pval>octsAlpha 
            isEqual(c,1)=1;
        else
            isEqual(c,1)=0;
        end
    end

    %select configuration 
    OCTsc=bestC;
    for c=1:Nconfigs
        if isEqual(c,1) && mMB(c,1) < mMB(OCTsc,1)
            OCTsc=c;
        end
    end    

end

