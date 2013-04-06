function reducesize(basename)

loadpaths

EEG = pop_loadset('filepath',filepath,'filename',[basename '.set']);
EEG = pop_select(EEG,'trial',1:round(EEG.trials/2));
pop_saveset(EEG,'savemode','resave');

end

