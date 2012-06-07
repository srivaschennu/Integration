function mergesets(filenames, savename)

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
% for sc = 1:length(sweepcodes)
%     EEG = struct([]);
%     for setidx = 1:length(filenames)
%         filename = filenames{setidx};
%         if isempty(EEG)
%             EEG = pop_loadset('filename', [filename '_' sweepcodes{sc} '.set'], 'filepath', filepath);
%         else
%             EEG = pop_mergeset(EEG, pop_loadset('filename', [filename '_' sweepcodes{sc} '.set'], 'filepath', filepath));
%         end
%         EEG = eeg_checkset(EEG);
%     end
%     pop_saveset(EEG,'filename', [savename '_' sweepcodes{sc} '.set'], 'filepath', filepath);
% end

EEG = struct([]);
for setidx = 1:length(filenames)
    filename = filenames{setidx};
    if isempty(EEG)
        EEG = pop_loadset('filename', [filename '.set'], 'filepath', filepath);
    else
        EEG = pop_mergeset(EEG, pop_loadset('filename', [filename '.set'], 'filepath', filepath));
    end
    EEG = eeg_checkset(EEG);
end
%EEG = pop_rmbase(EEG, [], [1 EEG.pnts]);
fprintf('Saving %s%s.set.\n', filepath, savename);
pop_saveset(EEG,'filename', [savename '.set'], 'filepath', filepath);