function EEG = epochdata(basename,sweepcode,doica)

loadpaths

if ~exist('doica','var') || isempty(doica)
    doica = true;
end

keepica = true;

switch sweepcode
    case 1
        eventlist = {
            '1000'
            '0100'
            '0010'
            '0001'
            '1100'
            '0011'
            '1010'
            '0101'
            };
        epochwin = [-7 13];

        condition = {
            'e1' {'1000'}
            'e2' {'0100'}
            'i1' {'0010'}
            'i2' {'0001'}
            'e1e2' {'1100'}
            'i1i2' {'0011'}
            'e1i1' {'1010'}
            'e2i2' {'0101'}
            'e1all' {'1000','1100','1010'}
            'e2all' {'0100','1100','0101'}
            'i1all' {'0010','0011','1010'}
            'i2all' {'0001','0011','0101'}
            };

    case 2
        eventlist = {
            '2000'
            '0200'
            '0020'
            '0002'
            '2200'
            '0022'
            '2020'
            '0202'
            };
        epochwin = [0 7];

        condition = {
            'e1' {'2000'}
            'e2' {'0200'}
            'i1' {'0020'}
            'i2' {'0002'}
            'e1e2' {'2200'}
            'i1i2' {'0022'}
            'e1i1' {'2020'}
            'e2i2' {'0202'}
            'e1all' {'2000','2200','2020'}
            'e2all' {'0200','2200','0202'}
            'i1all' {'0020','0022','2020'}
            'i2all' {'0002','0022','0202'}
            };

    case 3
        eventlist = {
            '3000'
            '0300'
            '0030'
            '0003'
            '3300'
            '0033'
            '3030'
            '0303'
            };
        epochwin = [0 1];

        condition = {
            'e1' {'3000'}
            'e2' {'0300'}
            'i1' {'0030'}
            'i2' {'0003'}
            'e1e2' {'3300'}
            'i1i2' {'0033'}
            'e1i1' {'3030'}
            'e2i2' {'0303'}
            'e1all' {'3000','3300','3030'}
            'e2all' {'0300','3300','0303'}
            'i1all' {'0030','0033','3030'}
            'i2all' {'0003','0033','0303'}
            };
        
    case 4
        eventlist = {
            '3000'
            '0300'
            '0030'
            '0003'
            '3300'
            '0033'
            '3030'
            '0303'
            '4000'
            '0400'
            '0040'
            '0004'
            '4400'
            '0044'
            '4040'
            '0404'
            };
        epochwin = [0 1];
        
        condition = {
            'e1' {'3000'}
            'e2' {'0300'}
            'i1' {'0030'}
            'i2' {'0003'}
            'e1e2' {'3300'}
            'i1i2' {'0033'}
            'e1i1' {'3030'}
            'e2i2' {'0303'}
            'e1all' {'3000','3300','3030'}
            'e2all' {'0300','3300','0303'}
            'i1all' {'0030','0033','3030'}
            'i2all' {'0003','0033','0303'}
            };
        
%     case 5
%         eventlist = {
%             '1000'
%             '0100'
%             '1100'
% %             '2000'
% %             '0200'
% %             '2200'
%             };
%         epochwin = [8 12];
%         condition = {};

end

if ischar(basename)
    EEG = pop_loadset('filename', [basename '_orig.set'], 'filepath', filepath);
else
    EEG = basename;
end

fprintf('Epoching and baselining.\n');
EEG = pop_epoch( EEG, eventlist, epochwin);

EEG.condition = condition;
EEG.freqs.e1 = [36 78];
EEG.freqs.e2 = [44 84];
EEG.freqs.i1 = 15.9574;
EEG.freqs.i2 = 19.8950;

EEG = pop_rmbase(EEG,[],[2 EEG.pnts]);

EEG = eeg_checkset( EEG );

if ischar(basename)
    if doica
        EEG.setname = [basename '_epochs'];
        EEG.filename = [basename '_epochs.set'];
    else
        EEG.setname = basename;
        EEG.filename = [basename '.set'];
    end
    
%     oldEEG = pop_loadset('filepath',filepath,'filename',EEG.filename);
%     EEG = pop_mergeset(oldEEG,EEG);
%     fprintf('merged data has %d epochs.\n',EEG.trials);
    
    if doica == true && keepica == true && exist([filepath EEG.filename],'file') == 2
        oldEEG = pop_loadset('filepath',filepath,'filename',EEG.filename,'loadmode','info');
        if isfield(oldEEG,'icaweights') && ~isempty(oldEEG.icaweights)
            fprintf('Loading existing info from %s%s.\n',filepath,EEG.filename);
            
            keepchan = [];
            for c = 1:length(EEG.chanlocs)
                if ismember({EEG.chanlocs(c).labels},{oldEEG.chanlocs.labels})
                    keepchan = [keepchan c];
                end
                EEG.chanlocs(c).badchan = 0;
            end
            rejchan = EEG.chanlocs(setdiff(1:length(EEG.chanlocs),keepchan));
            EEG = pop_select(EEG,'channel',keepchan);
            
            EEG.icaact = oldEEG.icaact;
            EEG.icawinv = oldEEG.icawinv;
            EEG.icasphere = oldEEG.icasphere;
            EEG.icaweights = oldEEG.icaweights;
            EEG.icachansind = oldEEG.icachansind;
            EEG.reject.gcompreject = oldEEG.reject.gcompreject;
            if isfield('oldEEG','rejchan')
                EEG.rejchan = oldEEG.rejchan;
            else
                EEG.rejchan = rejchan;
            end
        end
    end
    fprintf('Saving set %s%s.\n',filepath,EEG.filename);
    pop_saveset(EEG,'filename', EEG.filename, 'filepath', filepath);
end