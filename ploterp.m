function ploterp(subjlist,condlist,varargin)

loadpaths

timewin = [-1 3];

if ~isempty(varargin) && ~isempty(varargin{1})
    ylim = varargin{1};
else
    ylim = [-12 12];
end

if length(varargin) > 1 && ~isempty(varargin{2})
    subcond = varargin{2};
else
    subcond = false;
end

if length(varargin) > 2 && ~isempty(varargin{3})
    calcgfp = varargin{3};
else
    calcgfp = 0;
end

subjlists = {
    {
    'subj03_integration'
    'subj04_integration'
    'subj05_integration'
    'subj06_integration'
    'subj07_integration'
    };
    };

if ischar(subjlist)
    subjlist = {subjlist};
else
    subjlist = subjlists{subjlist};
end

diffdata = cell(length(subjlist));

for s = 1:length(subjlist)
    EEG = pop_loadset('filename', sprintf('%s.set', subjlist{s}), 'filepath', filepath);
    
    % rereference
    % EEG = rereference(EEG,1);
    
    EEG = pop_eegfilt(EEG,0,20, [], [0], 0, 0, 'fir1');
    EEG = pop_select(EEG,'time',timewin);
    EEG = pop_rmbase(EEG,[timewin(1) 0]*1000);
    
    
    if s == 1
        erpdata = zeros(EEG.nbchan,EEG.pnts,length(condlist),length(subjlist));
    end
    
    for c = 1:length(condlist)
        selectevents = EEG.condition{strcmp(condlist{c},EEG.condition(:,1)),2};
        typematches = false(1,length(EEG.epoch));
        
        for ep = 1:length(EEG.epoch)
            
            epochtype = EEG.epoch(ep).eventtype;
            if iscell(epochtype)
                epochtype = epochtype{cell2mat(EEG.epoch(ep).eventlatency) == 0};
            end
            if sum(strcmp(epochtype,selectevents)) > 0
                typematches(ep) = true;
            end
        end
        
        selectepochs = find(typematches);
        fprintf('Condition %s: found %d matching epochs.\n',condlist{c},length(selectepochs));
        erpdata(:,:,c,s) = mean(EEG.data(:,:,selectepochs),3);
        
        % subtract condition 1 from condition 2
        if subcond && c == 3
            erpdata(:,:,c,s) = erpdata(:,:,c,s) - (erpdata(:,:,1,s) + erpdata(:,:,2,s));
        end
        
    end
    
    %     diffdata{s} = pop_select(EEG,'trial',1);
    %     diffdata{s}.setname = sprintf('%s_%s-%s',subjlist{s},condlist{2},condlist{1});
    %     diffdata{s}.data = erpdata(:,:,2,s)-erpdata(:,:,1,s);
    %     pop_saveset(diffdata{s},'filepath',filepath,'filename',[diffdata{s}.setname '.set']);
    
end
erpdata = mean(erpdata,4);

if subcond
    erpdata = erpdata(:,:,3);
    condlist = {sprintf('%s-(%s+%s)',condlist{3},condlist{1},condlist{2})};
end

chanlocs = EEG.chanlocs;
if calcgfp
    chanlocs = EEG.chanlocs(strcmp('Cz',{EEG.chanlocs.labels}));
    chanlocs(1).label = 'GFP';
end

for c = 1:size(erpdata,3)
    plotdata = erpdata(:,:,c);
    
    if calcgfp
        plotdata = eeg_gfp(plotdata')';
    end
    
    [maxval, maxidx] = max(abs(plotdata),[],2);
    [~, maxmaxidx] = max(maxval);
    plottime = EEG.times(maxidx(maxmaxidx));
    if plottime == EEG.times(end)
        plottime = EEG.times(end-1);
    end
    
    figure('Name',condlist{c},'Color','white');
    timtopo(plotdata,chanlocs,...
        'limits',[EEG.times(1) EEG.times(end), ylim],...
        'plottimes',plottime);
end

% gadiff = diffdata{1};
% gadiff.data = erpdata(:,:,2)-erpdata(:,:,1);
% gadiff.setname = sprintf('%s-%s',condlist{2},condlist{1});
% pop_saveset(gadiff,'filepath',filepath,'filename',[gadiff.setname '.set']);