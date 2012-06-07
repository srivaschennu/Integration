function plotspec(EEG,cond,targetfreq)

loadpaths

evtype = EEG.condition{strcmp(cond,EEG.condition(:,1)),2};

if ischar(EEG)
    EEG = pop_loadset('filename', [EEG '.set'], 'filepath', filepath);
end

%chanexcl = [1,8,14,17,21,25,32,38,43,44,48,49,56,57,63,64,68,69,73,74,81,82,88,89,94,95,99,100,107,113,114,119,120,121,125,126,127,128];
chanexcl = [];

statwin = 10;
% stattest = 'T2';
% stattest = 'T2CIRC';
% stattest = 'SPEC';
%stattest = 'ABS';

alpha = 0.05;

%% select epochs
selectepochs = zeros(length(EEG.epoch),1);
for e = 1:length(EEG.epoch)
    epochevents = EEG.epoch(e).eventtype(cell2mat(EEG.epoch(e).eventlatency) == 0);
    for ce=1:length(epochevents)
        if sum(strcmp(epochevents{ce},evtype)) > 0
            selectepochs(e) = true;
        end
    end
end
selectepochs = find(selectepochs);

fprintf('Found %d matching epochs to keep.\n',length(selectepochs));
EEG = pop_select(EEG,'trial',selectepochs);

figure;
pop_spectopo(EEG, 1, [EEG.xmin  EEG.xmax]*1000, 'EEG' , 'freq', targetfreq,...
'freqrange',[0 100],'electrodes','off');
