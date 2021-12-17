function [] = exportsubplot(fig_name,m,n,i,basename,fs,dims,invert)
    figure(fig_name);
    s = subplot(m,n,i);
    fig = figure(99);
    copyobj(s,fig);
    set(gca,'Position',[0.1300 0.1100 0.7750 0.8150])
    drawnow
    exportfig([basename, '-', num2str(i),'.eps'],fs,dims,invert);
    pause(.5);
    close(99);
end