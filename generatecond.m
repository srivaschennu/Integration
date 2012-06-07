function generatecond(filename)

filepath = '/Users/chennu/Data/Integration/';

% sweepcodes = {
%     '1000'
%     '0100'
%     '0010'
%     '0001'
%     '1100'
%     '0011'
%     '1010'
%     '0101'
%     };
% 
% sweepcodes2 = {
%     '2000'
%     '0200'
%     '0020'
%     '0002'
%     '2200'
%     '0022'
%     '2020'
%     '0202'
%     };

sweepcodes3 = {
    '3000'
    '0300'
    '0030'
    '0003'
    '3300'
    '0033'
    '3030'
    '0303'
    };

EEG = pop_loadset('filename', [filename '.set'], 'filepath', filepath);

types = cell(1,EEG.trials);
for e = 1:EEG.trials
    for ev = 1:length(EEG.epoch(e).eventtype)
        if sum(strcmp(EEG.epoch(e).eventtype{ev},sweepcodes3)) == 1
            types{e} = EEG.epoch(e).eventtype{ev};
        end
    end
end

for s = 1:length(sweepcodes3)
    savename = [filename '_' sweepcodes3{s}];
    
    fprintf('Selecting %d epochs for condition %s.\n', sum(strcmp(sweepcodes3{s},types)), sweepcodes3{s});
    epochedEEG = pop_select( EEG, 'trial', find(strcmp(sweepcodes3{s},types)));
    epochedEEG.setname = savename;
    % fprintf('Filtering.\n');
    %EEG = pop_eegfilt(EEG,48,52,[],1);
    %EEG = pop_eegfilt(EEG,98,102,[],1);
    
    epochedEEG = eeg_checkset( epochedEEG );

    fprintf('Saving set %s%s.set.\n',filepath,savename);
    pop_saveset(epochedEEG,'filename', savename, 'filepath', filepath);
end