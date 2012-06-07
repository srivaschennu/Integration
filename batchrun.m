function batchrun

loadpaths

subjlist = {
    
'subj03_integration'
'subj04_integration'
'subj05_integration'
'subj06_integration'
'subj07_integration'
% 
% 'p0711_integration'
% 'p0811_integration'
% 'p0911_integration'
% 'p1011_integration'
% 'p1111_integration'
% 'p1211_integration'
% 'p1311_integration'
% 'p1411_integration'
% 'p1511_integration'
% 'p1611_integration'
% 'p0710V2_integration'
% 'p0510V2_integration'
% 'p1711_integration'
% 'p1811_integration'
% 'p1911_integration'
% 'p2011_integration'
% 'p2111_integration'
% 'p0411V2_integration'
% 'p0211V2_integration'
% 'p0311V2_integration'
% 'p0511V2_integration'
% 'p0112_integration'
};

condlist = {
    'e1', 36
    'e1all', 36
    'e1', 78
    'e1all', 78
    'e2', 44
    'e2all', 44
    'e2', 84
    'e2all', 84
    'i1', [15 17]
    'i1all', [15 17]
    'i2', [19 21]
    'i2all', [19 21]
    };
fig_nc = 2;

% condlist = {
%     'e1e2', 'e1', 36
%     'e1i1', 'e1', 36
%     'e1e2', 'e1i1', 36
%     'e1e2', 'e1', 78
%     'e1i1', 'e1', 78
%     'e1e2', 'e1i1', 78
%     'e1e2', 'e2', 44
%     'e2i2', 'e2', 44
%     'e1e2', 'e2i2', 44
%     'e1e2', 'e2', 84
%     'e2i2', 'e2', 84
%     'e1e2', 'e2i2', 84
%     'i1i2', 'i1', [15 17]
%     'e1i1', 'i1', [15 17]
%     'i1i2', 'e1i1', [15 17]
%     'i1i2', 'i2', [19 21]
%     'e2i2', 'i2', [19 21]
%     'i1i2', 'e2i2', [19 21]
%     };
% fig_nc = 3;


fig_nr = size(condlist,1)/fig_nc;


for s = 1:length(subjlist)
    subjname = subjlist{s};
    
    %EEG = pop_loadset('filepath',filepath,'filename',[subjname '.set']);
    %dataimport(subjname);
    %epochdata(subjname,1);
%     rejectic(subjname,[],1);
    rejartifacts2(subjname,2,3,0);
    
    %computeic(subjname);
    
%         figure('Name',mfilename,'Color','white');
%         figpos = get(gcf,'Position');
%         figpos(3) = figpos(3)*fig_nc;
%         figpos(4) = figpos(4)*fig_nr;
%         set(gcf,'Position',figpos);
%         plotidx = 1;
    
%     stat = cell(1,size(condlist,1));
    
% %     load(sprintf('%s_stat.mat',subjname),'stat');
%     
%     for c = 1:size(condlist,1)
%         
%         
%         stat{c} = fttest(EEG, condlist{c,1}, condlist{c,2}, [],0);
% %         stat{c} = fttest(EEG, condlist(c,[1 2]), condlist{c,3}, [],0);
%         
%                 plotvals = stat{c}.diffcond;
%                 plotvals(~stat{c}.mask) = 0;
%                 subplot(fig_nr,fig_nc,plotidx);
%                 topoplot(plotvals,stat{c}.chanlocs, 'maplimits', 'absmax', 'electrodes','on','pmask',stat{c}.mask);
%                 colorbar
%                 title(sprintf('%s: %s Hz',condlist{c,1},num2str(condlist{c,2})));
%                 plotidx = plotidx+1;
%     end
%     
%     save(sprintf('%s.mat',subjname),'stat');
%     saveas(gcf,sprintf('figures/%s.fig',subjname));
%     close(gcf);
end
