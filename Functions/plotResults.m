function plotResults(graphInfo,methodNames, DSHDt)

    red1=   [145 47 82]./255;
    green1=  [36 76 51]./255;
    green2=  [68 154 138]./255; 
    blue=  [58 67 110]./255;
    green= [140 152 70]./255; 
    lightblue=[76 151 184]./255; 
    grey=[0.5 0.5 0.5]; 
    black=[0 0 0]; 

    MarkerSize=15;
    XaxisSize=15;
    LabelSize=15;
    YaxisSize=12;

    if strcmp(graphInfo.causalGraph, 'DAG')
        if strcmp(graphInfo.dataType, 'mixed')
            markers={'o', '<', '>','p','square', 'd'}; 
            colors=[red1;green1; green2;green; grey; black ];
        else
            markers={'o', '<', '>','p','square', 'd'}; 
            colors=[red1;blue; lightblue;green; grey; black ]; 
        end

    elseif strcmp(graphInfo.causalGraph, 'MAG')
        if strcmp(graphInfo.dataType, 'continuous')
            markers={'o', '<', 'p','square', 'd'}; 
            colors=[red1;blue; green; grey; black ]; 
        else
            markers={'o', 'p','square', 'd'}; 
            colors=[red1;green; grey; black ];
        end
    end

    methodsD=methodNames(2:end);
    Nmethods=length(methodsD); 


    figure;
    for m=1:Nmethods
        meDag=mean(DSHDt.(methodsD{m}));
        stDag=std(DSHDt.(methodsD{m}))/sqrt(length(DSHDt.(methodsD{m})));
        e=errorbar(m, meDag, stDag);
        e.Marker=markers{m};
        e.MarkerSize=MarkerSize;
        e.Color=colors(m,:);
        e.MarkerFaceColor='auto';
        e.LineWidth=1;
        e.LineStyle='none';
        hold on
    end
    grid on
    ax=gca;
    ax.XTick=[];
    ax.XAxis.FontSize = XaxisSize;
    ax.YAxis.FontSize = YaxisSize;
    ylim([0,Inf]);
    xlim([0, m+3]);
    ylabel({sprintf('\\Delta %s','SHD'), " "}, 'FontSize',LabelSize);
    title('Tuning Performance', 'FontSize',LabelSize, 'FontWeight', 'normal');

    lgd=legend({methodsD{:}});
    lgd.FontSize=10;
    hold off;

end
