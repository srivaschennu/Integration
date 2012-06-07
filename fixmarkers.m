function EEG = fixmarkers(EEG)

sweepcodes = {
    '1000'
    '0100'
    '0010'
    '0001'
    '1100'
    '0011'
    '1010'
    '0101'
    };

sweepcodes2 = {
    '2000'
    '0200'
    '0020'
    '0002'
    '2200'
    '0022'
    '2020'
    '0202'
    };

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


% e = 1;
% while true
% types = {EEG.event.type};
%     if sum(strcmp(EEG.event(e).type, sweepcodes)) == 1
%         sc = find(strcmp(EEG.event(e).type, sweepcodes));
%         nextidx = find(strcmp(EEG.event(e).type, types(e+1:end)), 1, 'first');
%         EEG.event(e+nextidx).type = sweepcodes2{sc};
%         fprintf('%s found at %d. replaced at %d.\n', EEG.event(e).type, e, e+nextidx);
%         
%         newevent = EEG.event(e);
%         newevent.type = sweepcodes3{sc};
%         for i=1:13
%             EEG.event = [EEG.event(1:e+i-1) newevent EEG.event(e+i:end)];
%             newevent.latency = newevent.latency+EEG.srate;
%         end
%     end
%     e = e+1;
%     if e == length(EEG.event)
%         break;
%     end
% end
% EEG = eeg_checkset(EEG, 'eventconsistency');

for e = 1:length(EEG.event)
    if sum(strcmp(EEG.event(e).type, sweepcodes2)) == 1
        sc = find(strcmp(EEG.event(e).type, sweepcodes2));
        EEG.event(e).type = sweepcodes3{sc};
    elseif sum(strcmp(EEG.event(e).type, sweepcodes3)) == 1
        sc = find(strcmp(EEG.event(e).type, sweepcodes3));
        EEG.event(e).type = sweepcodes2{sc};
    end
end

EEG = eeg_checkset(EEG, 'eventconsistency');