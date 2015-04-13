function pipeline(basename)

loadpaths

dataimport(basename);
epochdata(basename,4);
rejartifacts2([basename '_epochs'],1,4);
computeic([basename '_epochs']);
epochdata(basename,1);
rejectic(basename);
rejartifacts2(basename,2,3);

EEG = pop_loadset('filepath',filepath,'filename',[basename '.set']);
fttest(EEG,'e1',36);
fttest(EEG,'e1all',36);
fttest(EEG,'e1',78);
fttest(EEG,'e2all',78);

fttest(EEG,'i1',[15 17])
fttest(EEG,'i1all',[15 17])
fttest(EEG,'i2',[19 21])
fttest(EEG,'i2all',[19 21])

end