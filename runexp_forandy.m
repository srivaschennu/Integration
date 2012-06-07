function runexp(paramfile)

tStart = tic;

fprintf('Loading parameters.\n');
%load stimulation parameters
load(paramfile);

%% prep stimuli
fprintf('Initialising audio.\n');

% initialise psychtoolbox
InitializePsychSound

if PsychPortAudio('GetOpenDeviceCount') == 1
    PsychPortAudio('Close',0);
end

audiodevices = PsychPortAudio('GetDevices');
outdevice = strcmp('Built-in Output',{audiodevices.DeviceName});
pahandle = PsychPortAudio('Open',audiodevices(outdevice).DeviceIndex,[],[],f_sample,2);

% generate amplitude and frequency modulated stimuli for generating
% ASSRs. e1data and e2data for for ear 1 (left) and ear 2 (right)
e1data = amfm(f_sample,sweeptypes(1).E1FC,sweeptypes(1).E1FM,sweepon);
e2data = amfm(f_sample,sweeptypes(1).E2FC,sweeptypes(1).E2FM,sweepon);

%% init variables
numsweeptypes = length(sweeptypes);
sweeporder = repmat(1:numsweeptypes, 1, numrep);

%variables to store run info and responses
sweepdata = zeros(numblocks,length(sweeporder));
respdata = zeros(numblocks,length(sweeporder));
resptime = zeros(numblocks,length(sweeporder));

%setup random number generator based on clock
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));

%% begin block loop
for b = 1:numblocks
    sweeporder = sweeporder(randperm(length(sweeporder)));
    sweepdata(b,:) = sweeporder;
    
    
    fprintf('Block %d: %d repetitions of %d sweep types of %d sec each.\n', ...
        b, numrep, numsweeptypes, sweepon+sweepoff);
    
    %% begin sweep loop
    for t = 1:size(sweeporder,2)
        s = sweeporder(t);
        
        fprintf('\nBlock %d Sweep %d.\n', b, t);
        
        %% setup stimulation
        
        if sweeptypes(s).E1ST == 1 || sweeptypes(s).E2ST == 1
            %setup ear stimulation for this sweep
            leftdata = zeros(f_sample*sweepon,1);
            rightdata = zeros(f_sample*sweepon,1);
            if sweeptypes(s).E1ST == 1
                fprintf('Ear 1: Fc %dHz, Fm %dHz.\n', sweeptypes(s).E1FC,sweeptypes(s).E1FM);
                leftdata = e1data;
            end
            if sweeptypes(s).E2ST == 1
                fprintf('Ear 2: Fc %dHz, Fm %dHz.\n', sweeptypes(s).E2FC,sweeptypes(s).E2FM);
                rightdata = e2data;
            end
            stimdata = cat(2,leftdata,rightdata);
            PsychPortAudio('FillBuffer',pahandle,stimdata');
        end
        
        %% start stimulation
        starttime = GetSecs;
        stoptime = starttime + sweepon;
        
        %start sound
        if sweeptypes(s).E1ST == 1 || sweeptypes(s).E2ST == 1
            starttime = PsychPortAudio('Start',pahandle,1,0,1);
            stoptime = starttime + sweepon;
        end
        
        fprintf('Sweep start.\n');
        
        %wait till stoptime
        while GetSecs <= stoptime
        end
        
        %% stop stimulation
        
        fprintf('Sweep stop.\n');
        
        stoptime = GetSecs + sweepoff;
        %wait for 'sweepoff' seconds
        while GetSecs <= stoptime
        end
    end
    
    if b < numblocks
        choice = questdlg(sprintf('Finished Block %d. Continue?', b), 'Experiment', 'Yes', 'No', 'Yes');
        
        switch choice
            case 'Yes'
            case 'No'
                break
            otherwise
                break
        end
    end
end

%% finish up
fprintf('\n');

fprintf('Finishing up.\n');

%close audio device
PsychPortAudio('Close',pahandle);

fprintf('Run took %.1f minutes.\n', toc(tStart) / 60);