function batchrun

loadpaths

subjlist = {
    
% 'subj03_integration'
% 'subj04_integration'
% 'subj05_integration'
% 'subj06_integration'
% 'subj07_integration'
'SJ_integration'
'IC_integration'
'GR_integration'
'VN_integration'
'BMS_integration'
};

% 'p0711_integration'
% 'p0811_integration'
% % 'p0911_integration' %BAD
% 'p1011_integration'
% % 'p1111_integration' %BAD
% 'p1211_integration'
% 'p1311_integration'
% 'p1411_integration'
% 'p1511_integration'
% 'p1611_integration'
% 'p0710V2_integration' %NOISY
% 'p0510V2_integration'

%RUN EPOCHDATA AND REJARTIFACTS2 ON THESE BEFORE ICA

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
% };

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
    
%                 javaaddpath('/Users/chennu/Work/mffimport/MFF-1.0.d0004.jar');
%                 filenames = dir(sprintf('%s%s*', filepath, subjname));
%                 mfffiles = filenames(logical(cell2mat({filenames.isdir})));
%                 filename = mfffiles.name;
%     
%                 fprintf('Reading information from %s%s.\n',filepath,filename);
%                 mffinfo = read_mff_info([filepath filename]);
%                 mffdate = sscanf(mffinfo.date,'%d-%d-%d');
%                 fprintf('%s: %02d/%02d/%04d\n',subjname,mffdate(3),mffdate(2),mffdate(1));
%                 subjinfo = read_mff_subj([filepath filename])

% EEG = pop_loadset('filepath',filepath,'filename',[subjname '_epochs.set'],'loadmode','info');
%     fprintf('%s %d\n',subjname,EEG.trials);
%     channames = sort({EEG.chanlocs.labels});
%     if exist('oldchannames','var')
%         if sum(strcmp(oldchannames,channames)) ~= length(channames)
%             error('%s\n%s\n',cell2str(channames),cell2str(oldchannames));
%         else
%             fprintf('%s\n%s\n',cell2str(channames),cell2str(oldchannames));
%         end
%     else
%         oldchannames = channames;
%     end

%     dataimport(subjname);
%     epochdata(subjname,4);
    
%     rejartifacts2([subjname '_epochs'],1,4,[],[],1000,500);
%     computeic([subjname '_epochs']);
    
%     epochdata(subjname,1);
%     rejectic(subjname);
plotcomp(subjname,'i1i2',[15 17]);
plotcomp(subjname,'i1i2',[19 21]);

%     rejartifacts2(subjname,2,3);
    
    
    
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
%                 plotvals(~stat{c}.mask) = 0;{rejchan.labels}
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
