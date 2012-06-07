function fftdiff(EEG,evtype,targetfreq,chanidx,xlim,ylim)

filepath = '/Users/chennu/Data/Integration/';

if ischar(EEG)
    EEG = pop_loadset('filename', [EEG '_epochs.set'], 'filepath', filepath);
end

refchannels = [57 100];
%refchannels = [];

siglevel = 0.05;

chanexcl = [1,8,14,17,21,25,32,38,43,44,48,49,56,57,63,64,68,69,73,74,81,82,88,89,94,95,99,100,107,113,114,119,120,121,125,126,127,128];
%chanexcl = [];

%% select epochs
group1epochs = zeros(length(EEG.epoch),1);
group2epochs = zeros(length(EEG.epoch),1);

for e = 1:length(EEG.epoch)
    epochevents = EEG.epoch(e).eventtype(cell2mat(EEG.epoch(e).eventlatency) == 0);
    if sum(strcmp(evtype{1},epochevents)) > 0
        group1epochs(e) = true;
    elseif sum(strcmp(evtype{2},epochevents)) > 0
        group2epochs(e) = true;
    end
end

group1epochs = find(group1epochs);
group2epochs = find(group2epochs);
fprintf('Found %d epochs in group 1 and %d in group 2.\n',length(group1epochs),length(group2epochs));

EEG = pop_select(EEG,'trial',union(group1epochs,group2epochs));

group1epochs = zeros(length(EEG.epoch),1);
group2epochs = zeros(length(EEG.epoch),1);

for e = 1:length(EEG.epoch)
    epochevents = EEG.epoch(e).eventtype(cell2mat(EEG.epoch(e).eventlatency) == 0);
    if sum(strcmp(evtype{1},epochevents)) > 0
        group1epochs(e) = true;
    elseif sum(strcmp(evtype{2},epochevents)) > 0
        group2epochs(e) = true;
    end
end

group1epochs = find(group1epochs);
group2epochs = find(group2epochs);

%% find bad channels
if isfield(EEG.chanlocs,'badchan')
    badchannels = find(cell2mat({EEG.chanlocs.badchan}));
    fprintf('Found %d bad channels:',length(badchannels));
    fprintf(' %d',badchannels);
    fprintf('.\n');
else
    fprintf('No bad channel info found.\n');
    badchannels = [];
end

%% re-reference
if ~isempty(refchannels)
    fprintf('Re-referencing to channels [%s].\n',num2str(refchannels));
    EEG = pop_reref(EEG,refchannels,'exclude',badchannels,'keepref','on');
else
        chanlocs = [cell2mat({EEG.chanlocs.X})' cell2mat({EEG.chanlocs.Y})' cell2mat({EEG.chanlocs.Z})'];
        EEG.data = permute(lar(permute(EEG.data,[3 2 1]), chanlocs, badchannels),[3 2 1]);
    %EEG = pop_reref(EEG,[],'exclude',badchannels);
end

if exist('chanidx','var') && ~isempty(chanidx)
    EEG.data = EEG.data(chanidx,:,:);
    EEG.nbchan = 1;
    EEG.chanlocs = EEG.chanlocs(chanidx);
    chanidx = 1;
end

%% Calculate single trial FFT
fprintf('Calculating single trial FFT.\n');
Y = zeros(EEG.nbchan,EEG.pnts,length(group1epochs)+length(group2epochs));

for c=1:EEG.nbchan
    for e = union(group1epochs,group2epochs)
        Y(c,:,e) = fft(squeeze(EEG.data(c,:,e)));
    end
end

NFFT = EEG.pnts;
NumUnqiuePoints = ceil((NFFT+1)/2);
Y = Y(:,1:NumUnqiuePoints,:);
freqs = linspace(0,1,NumUnqiuePoints)*(EEG.srate/2);

%% Averaging
%variance weighted average
if ~isempty(targetfreq)
    filtereddata = eegfilt(EEG.data,EEG.srate,targetfreq(1)-10,targetfreq(end)+10);
    filtereddata = reshape(filtereddata,EEG.nbchan,EEG.pnts,EEG.trials);
    %trvar = squeeze(var(permute(filtereddata,[2 1 3])));
    trvar = squeeze(var(filtereddata,0,2));
else
    trvar = squeeze(var(EEG.data,0,2));
end

if EEG.nbchan == 1
    trvar = trvar';
end

fprintf('Averaging %d group 1 trials.\n', length(group1epochs));
avY1 = zeros(size(EEG.data,1),size(EEG.data,2));
for ch = 1:EEG.nbchan
    for t = 1:length(group1epochs)
        avY1(ch,:) = avY1(ch,:) + (EEG.data(ch,:,group1epochs(t)) ./ trvar(ch,group1epochs(t)));
    end
    avY1(ch,:) = avY1(ch,:) ./ sum(1./trvar(ch,:));
end

%% Calculate mean FFT
fprintf('Calculating average FFT.\n');
avY1 = fft(avY1')';
avY1 = avY1(:,1:NumUnqiuePoints);
avY1 = avY1/NFFT; %scale magnitude by length of FFT
%avY1 = avY1.^2; %square mag to get power

if rem(NFFT, 2) %multiply power by 2 (except DC comp and nyquist targetfreq, if it exists)
    avY1(:,2:end) = avY1(:,2:end)*2;
else
    avY1(:,2:end-1) = avY1(:,2:end-1)*2;
end
mY1 = abs(avY1); %get magnitude


fprintf('Averaging %d group 2 trials.\n', length(group2epochs));
avY2 = zeros(size(EEG.data,1),size(EEG.data,2));
for ch = 1:EEG.nbchan
    for t = 1:length(group2epochs)
        avY2(ch,:) = avY2(ch,:) + (EEG.data(ch,:,group2epochs(t)) ./ trvar(ch,group2epochs(t)));
    end
    avY2(ch,:) = avY2(ch,:) ./ sum(1./trvar(ch,:));
end

%normal average
%avY = mean(EEG.data,3);

%% Calculate mean FFT
fprintf('Calculating average FFT.\n');
avY2 = fft(avY2')';
avY2 = avY2(:,1:NumUnqiuePoints);
avY2 = avY2/NFFT; %scale magnitude by length of FFT
%avY2 = avY2.^2; %square mag to get power

if rem(NFFT, 2) %multiply power by 2 (except DC comp and nyquist targetfreq, if it exists)
    avY2(:,2:end) = avY2(:,2:end)*2;
else
    avY2(:,2:end-1) = avY2(:,2:end-1)*2;
end
mY2 = abs(avY2); %get magnitude

%% Statistical testing and topoplot
if ~isempty(targetfreq)
    fidx = find(freqs >= targetfreq(1),1,'first'):find(freqs >= targetfreq(end),1,'first');
end

if ~exist('chanidx','var')
    fY = squeeze(mean(Y(:,fidx,:),2));
    plotchans = setdiff(1:EEG.nbchan,chanexcl);
    
    groups = cat(2,ones(1,length(group1epochs)),ones(1,length(group2epochs))+1);
    p = zeros(1,EEG.nbchan);
    for ch = 1:EEG.nbchan
        %p(ch) = manova1([real(fY(ch,:))' imag(fY(ch,:))'],groups');
        p(ch) = anova1(abs(fY(ch,:))',groups','off');
    end
    
%     p(chanexcl) = 1;
%     p(badchannels) = 1;
%     %p(p>siglevel) = 1;
%     %p(p ~= 0) = 1 - p(p ~= 0);
%     figure; topoplot((1-p(plotchans)),EEG.chanlocs(plotchans), 'maplimits', [0 1], 'electrodes','labels');
%     h = colorbar; set(h,'YTick',[0 1],'YTickLabel',{'1','0'});

    
    %chanincl = EEG.idx1020;
    %    plotchans = setdiff(plotchans,badchannels);
    %    plotchans = intersect(plotchans, find(p < siglevel));
        
    fprintf('Plotting topoplot.\n');
    figure; 

    plotvals = mean(mY1(:,fidx),2);
    plotvals(chanexcl) = 0;
    plotvals(badchannels) = 0;
    subplot(1,3,1); topoplot(plotvals(plotchans),EEG.chanlocs(plotchans), 'maplimits', 'absmax');%, 'electrodes','labels');
    colorbar
    
    plotvals = mean(mY2(:,fidx),2);
    plotvals(chanexcl) = 0;
    plotvals(badchannels) = 0;
    subplot(1,3,2); topoplot(plotvals(plotchans),EEG.chanlocs(plotchans), 'maplimits', 'absmax');%, 'electrodes','labels');
    colorbar
    
    plotvals = mean(mY1(:,fidx),2)-mean(mY2(:,fidx),2);
    plotvals(chanexcl) = 0;
    plotvals(badchannels) = 0;
    plotvals(p > siglevel) = 0;
    subplot(1,3,3); topoplot(plotvals(plotchans),EEG.chanlocs(plotchans), 'maplimits', 'absmax');%, 'electrodes','labels');
    colorbar
end

%% FFT Plotting
if exist('chanidx','var') && ~isempty(chanidx)
    fprintf('Plotting FFT.\n');
    figure; plot(freqs,mean(mY1(chanidx,:),1),freqs,mean(mY2(chanidx,:),1),'LineWidth',2);
    set(gca,'FontSize',14);
    if exist('xlim', 'var') && ~isempty(xlim)
        set(gca,'XLim',xlim);
    end
    if exist('ylim', 'var') && ~isempty(ylim)
        set(gca,'YLim',ylim);
    end
    
    xlabel('Frequency (Hz)','FontSize',14);
    ylabel('Amplitude (uV)','FontSize',14);
    title(sprintf('FFT at %s', EEG.chanlocs(chanidx).labels));
    box on
end
