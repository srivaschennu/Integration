function plotcomp(basename,cond,freqband)

loadpaths

bandlen = length(freqband(2)-freqband(1));

filename = [basename '_epochs.set'];
EEG = pop_loadset('filename', filename, 'filepath', filepath);

% select epochs for condition
evtype = EEG.condition{strcmp(cond,EEG.condition(:,1)),2};
condepochs = zeros(length(EEG.epoch),1);

for e = 1:length(EEG.epoch)
    epochevents = EEG.epoch(e).eventtype(cell2mat(EEG.epoch(e).eventlatency) == 0);
    for ce=1:length(epochevents)
        if sum(strcmp(epochevents{ce},evtype)) > 0
            condepochs(e) = true;
        end
    end
end
condepochs = find(condepochs);
fprintf('%s: found %d matching epochs to keep.\n',cond,length(condepochs));
EEG = pop_select(EEG,'trial',condepochs);


data = (EEG.icaweights*EEG.icasphere)*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts);
data = reshape( data, size(data,1), EEG.pnts, EEG.trials);
[spectra,freqs] = spectopo(data,EEG.pnts,EEG.srate,'plot','off');

meanpwr(:,1) = mean(spectra(:,freqs >= freqband(1) & freqs <= freqband(2)),2);
meanpwr(:,2) = mean(spectra(:,(freqs >= freqband(1)-bandlen & freqs < freqband(1)) | ...
    (freqs > freqband(2) & freqs <=freqband(2)+bandlen)),2);

meanpwr = meanpwr(:,1) - meanpwr(:,2);
mpwridx = find(meanpwr > 1);

if ~isempty(mpwridx)
    meanpwr = meanpwr(mpwridx);
    [~,sortorder] = sort(meanpwr,'descend');
    sortorder = mpwridx(sortorder);
    
    rejectic(basename,'sortorder',sortorder');
else
    fprintf('plotcomp: No components found to plot!\n');
end