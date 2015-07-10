function prcPlot(maxI,meanI,percentiles,prcSpec)

try clf(1), catch, figure(1), end
PlPrc = plot(percentiles); hold on
PlMean = plot(meanI,'--k','linewidth',2);
PlMax = plot(maxI,':k','linewidth',1);
%cYlim = get(gca,'ylim');
%nYlim = max(max(([percentiles(:,end) meanI])));
axis tight
%set(gca,'ylim',[cYlim(1) nYlim*1.1])
title('Percentiles of data numbers')
xlabel('Frame #')
ylabel('Data Number') 





for k = 1:length(prcSpec)
lgTxt{k} = num2str(prcSpec(k));
end
lgTxt{end+1} = 'mean';
lgTxt{end+1} = 'max';
try
legend(lgTxt)
end
