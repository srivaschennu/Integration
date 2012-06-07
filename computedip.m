function computedip(basename)

loadpaths

if ischar(basename)
    EEG = pop_loadset('filename', sprintf('%s_epochs.set', basename), 'filepath', filepath);
else
    EEG = basename;
end

if ~strcmp(EEG.ref,'averef')
    EEG = pop_reref(EEG,[]);
end

if ~isfield(EEG,'dipfit') || isempty(EEG.dipfit)
    EEG = pop_dipfit_settings( EEG, 'hdmfile','/Users/chennu/Work/MATLAB/eeglab/plugins/dipfit2.2/standard_BEM/standard_vol.mat',...
        'coordformat','MNI','mrifile','/Users/chennu/Work/MATLAB/eeglab/plugins/dipfit2.2/standard_BEM/standard_mri.mat',...
        'chanfile','/Users/chennu/Work/MATLAB/eeglab/plugins/dipfit2.2/standard_BEM/elec/standard_1005.elc',...
        'coord_transform',[0.46462 -16.108 -3.5484 0.082444 0.0055792 -1.5693 11.0602 11.4353 11.5217] ,'chansel',[1:128] );
    EEG = pop_multifit(EEG, [1:128] ,'threshold',20,'rmout','on','dipplot','on','plotopt',{'normlen' 'on'});
    EEG.saved = 'no';
    pop_saveset(EEG,'savemode','resave');
end

[~, icbyrv] = sort(cell2mat(({EEG.dipfit.model.rv})));

pop_topoplot(EEG,0, icbyrv(1:20) ,EEG.setname,0 ,1,'electrodes','off');

epochlist  = {'3000','3300','3030'};

%epochEEG = pop_selectevent(EEG,'type',epochlist);

