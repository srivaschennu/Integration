function Integration(paramfile)

if nargin == 0 || ~exist('paramfile','var')
    paramfile = 'param_patient.mat';
end

ts = fix(clock);

if ispc
    datapath = 'data\';
elseif ismac
    datapath = 'data/';
end

if ~exist(datapath,'dir')
    mkdir(datapath)
end

datafile = sprintf('%s %d-%d-%d %d-%d-%d.mat',datapath,ts(3),ts(2),ts(1),ts(4),ts(5),ts(6));


tStart = tic;

fprintf('Loading parameters from %s.\n',paramfile);
%load parameters
load(paramfile);

%% prep devices
if ~exist('DEBUG','var') || DEBUG == 0
    if exist('srboxport','var') && ~isempty(srboxport)
        %connect to srbox
        fprintf('Connecting to srbox port %s.\n', srboxport);
        srboxporth = CMUBox('Open', 'pst', srboxport, 'norelease');
        if srboxporth == 0
            error('Could not open srbox port %s.\n', srboxport);
        end
    else
        srboxporth = 0;
    end
    
    %connect to DMX
    fprintf('Initialising audio.\n');

    InitializePsychSound
    
    if PsychPortAudio('GetOpenDeviceCount') == 1
        PsychPortAudio('Close',0);
    end
    
    %Try Terratec DMX ASIO driver first. If not found, revert to
    %native sound device
    if ispc
        audiodevices = PsychPortAudio('GetDevices',3);
        if ~isempty(audiodevices)
            %DMX audio
            outdevice = strcmp('DMX 6Fire USB ASIO Driver',{audiodevices.DeviceName});
            hd.outdevice = 'dmx';
        else
            %Windows default audio
            audiodevices = PsychPortAudio('GetDevices',2);
            outdevice = strcmp('Microsoft Sound Mapper - Output',{audiodevices.DeviceName});
            hd.outdevice = 'base';
        end
    elseif ismac
        audiodevices = PsychPortAudio('GetDevices');
        %DMX audio
        outdevice = strcmp('TerraTec DMX 6Fire USB',{audiodevices.DeviceName});
        hd.outdevice = 'dmx';
        if sum(outdevice) ~= 1
            %Mac default audio
            audiodevices = PsychPortAudio('GetDevices');
            outdevice = strcmp('Built-in Output',{audiodevices.DeviceName});
            hd.outdevice = 'base';
        end
    else
        error('Unsupported OS platform!');
    end
    
    pahandle = PsychPortAudio('Open',audiodevices(outdevice).DeviceIndex,[],[],f_sample,2);
    
    e1data = amfm(f_sample,sweeptypes(1).E1FC,sweeptypes(1).E1FM,sweepon);
    e2data = amfm(f_sample,sweeptypes(1).E2FC,sweeptypes(1).E2FM,sweepon);
    
    %connect to netstation
    if exist('nshost','var') && ~isempty(nshost) && ...
            exist('nsport','var') && nsport ~= 0
        fprintf('Connecting to NetStation at %s:%d.\n', nshost, nsport);
        [nsstatus, nserror] = NetStation('Connect',nshost,nsport);
        if nsstatus ~= 0
            error('Could not connect to NetStation host %s:%d.\n%s\n', ...
                nshost, nsport, nserror);
            return;
        end
    end
    NetStation('Synchronize');
    
    %connect to goggles controller
    fprintf('Connecting to goggles port 0x%s.\n', gogglesport);
    gogglesport = hex2dec(gogglesport);

    gogglesportobj = io32;
    gogglesportstatus = io32(gogglesportobj);
    
    if gogglesportstatus ~= 0
        error('Could not open goggles port.\n');
    end
    
    %initialise googles and set up mode
    visual_state = 0;
    io32(gogglesportobj,gogglesport,visual_state);
    
    mb_handle = msgbox({'Ensure that:','','-  Inset earphone jack is connected to the Terratec box, NOT the laptop',...
        '- "Waveplay 1/2" volume in the panel below is set to -8dB','',...
        'Put goggles on participant and press OK to continue.'},'Integration','warn');
    boxpos = get(mb_handle,'Position');
    set(mb_handle,'Position',[boxpos(1) boxpos(2)+125 boxpos(3) boxpos(4)]); 
    system('C:\Program Files\TerraTec\DMX6FireUSB\DMX6FireUSB.exe');
    if ishandle(mb_handle)
        uiwait(mb_handle);
    end
end

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
    
    NetStation('Synchronize');
    pause(1);
    %start recording
    NetStation('StartRecording');
    pause(1);
    
    %send block begin marker
    NetStation('Event', 'BGIN', GetSecs, 0.001, 'BNUM',b);
    
    fprintf('Block %d: %d repetitions of %d sweep types of %d sec each.\n', ...
        b, numrep, numsweeptypes, sweepon+sweepoff);
    
    %% begin sweep loop
    for t = 1:size(sweeporder,2)
        s = sweeporder(t);
        
        fprintf('\nBlock %d Sweep %d.\n', b, t);
        
        %clear srbox
        if srboxporth ~= 0
            while true
                srboxevent = CMUBox('GetEvent', srboxporth);
                if isempty(srboxevent)
                    break;
                end
            end
        end
        
        %% setup stimulation
        
        if sweeptypes(s).E1ST == 1 || sweeptypes(s).E2ST == 1
            %setup ear stimulation for this sweep
            leftdata = zeros(f_sample*sweepon,1);
            rightdata = zeros(f_sample*sweepon,1);
            if sweeptypes(s).E1ST == 1
                for f = 1:length(sweeptypes(s).E1FC)
                    fprintf('Ear 1: Fc %dHz, Fm %dHz.\n', sweeptypes(s).E1FC(f),sweeptypes(s).E1FM(f));
                end
                leftdata = e1data;
            end
            if sweeptypes(s).E2ST == 1
                for f = 1:length(sweeptypes(s).E2FC)
                    fprintf('Ear 2: Fc %dHz, Fm %dHz.\n', sweeptypes(s).E2FC(f),sweeptypes(s).E2FM(f));
                end
                rightdata = e2data;
            end
            stimdata = cat(2,leftdata,rightdata);
            PsychPortAudio('FillBuffer',pahandle,stimdata');
        end
        
        if sweeptypes(s).I1ST == 1 || sweeptypes(s).I2ST == 1
            %setup eye stimulation for this sweep
            visual_state = 0;
            if sweeptypes(s).I1ST == 1
                fprintf('Eye 1: Ff %.2fHz.\n', sweeptypes(s).I1FF);
                visual_state = 1;
            end
            if sweeptypes(s).I2ST == 1
                fprintf('Eye 2: Ff %.2fHz.\n', sweeptypes(s).I2FF);
                visual_state = 2;
            end
            if sweeptypes(s).I1ST == 1 && sweeptypes(s).I2ST == 1
                visual_state = 3;
            end
        end
        
        %% marker preparation
        
        %prepare marker containing stimulation parameters
        cmdstr = 'NetStation(''Event'', evtype, evtime, 0.001';
        fnlist = fieldnames(sweeptypes(s));
        for fn = 1:length(fnlist)
            fval = sweeptypes(s).(fnlist{fn});
            for fv = 1:length(fval)
                cmdstr = [cmdstr ', ''' fnlist{fn} num2str(fv) ''', ' num2str(fval(fv))];
            end
        end
        cmdstr = [cmdstr ');'];
        
        %% start stimulation
        starttime = GetSecs;
        stoptime = starttime + sweepon;
        
        %start sound
        if sweeptypes(s).E1ST == 1 || sweeptypes(s).E2ST == 1
            starttime = PsychPortAudio('Start',pahandle,1,0,1);
            stoptime = starttime + sweepon;
        end

        %start googles
        if sweeptypes(s).I1ST == 1 || sweeptypes(s).I2ST == 1
            io32(gogglesportobj,gogglesport,visual_state);
        end
        
        %send sweep start marker
        evtype = [num2str(sweeptypes(s).E1ST) num2str(sweeptypes(s).E2ST) num2str(sweeptypes(s).I1ST) num2str(sweeptypes(s).I2ST)];
        evtime = starttime;
        eval(cmdstr);
        
        %send first marker
        evtype = [num2str(sweeptypes(s).E1ST*3) num2str(sweeptypes(s).E2ST*3) num2str(sweeptypes(s).I1ST*3) num2str(sweeptypes(s).I2ST*3)];
        evtime = starttime+0.001;
        NetStation('Event', evtype, evtime);
%         eval(cmdstr);
        
        fprintf('Sweep start.\n');
        
        %wait till stoptime
        while GetSecs <= stoptime
            curtime = GetSecs;
            
            %send marker regularly
            if curtime - evtime >= markerinterval && curtime + 0.1 <= stoptime
                evtime = curtime;
                NetStation('Event', evtype, evtime);
                %eval(cmdstr);
            end
            
            %read input from srbox
            if srboxporth ~= 0 && respdata(b,t) == 0
                srboxevent = CMUBox('GetEvent', srboxporth);
                %send response marker and store response time
                if ~isempty(srboxevent)
                    if sum(srboxevent.state == validresp) == 1
                        resptime(b,t) = curtime;
                        respdata(b,t) = srboxevent.state;
                        NetStation('Event', 'BTNP', resptime(b,t), 0.001, ...
                            'VALU', respdata(b,t));
                        resptime(b,t) = resptime(b,t) - starttime;
                        fprintf('BTN%d at %.1fs: ', respdata(b,t), resptime(b,t));
                        if respdata(b,t) == sweeptypes(s).RESP
                            fprintf('CORRECT.\n');
                        else
                            fprintf('INCORRECT.\n');
                        end
                    else
                        fprintf('Invalid response code %d.\n', srboxevent.state);
                    end
                end
            end
        end
        
        %% stop stimulation
        %stop goggles
        if sweeptypes(s).I1ST == 1 || sweeptypes(s).I2ST == 1
            visual_state = 0;
            io32(gogglesportobj,gogglesport,visual_state);
        end
        
        %send stop marker
        %evtype = 'STOP';
        evtype = [num2str(sweeptypes(s).E1ST*2) num2str(sweeptypes(s).E2ST*2) num2str(sweeptypes(s).I1ST*2) num2str(sweeptypes(s).I2ST*2)];
        evtime = stoptime;
        eval(cmdstr);
        
        fprintf('Sweep stop.\n');
        
        stoptime = GetSecs + sweepoff;
        %wait for 'sweepoff' seconds
        while GetSecs <= stoptime
        end
    end
    
    %send block end marker
    NetStation('Event', 'BEND', GetSecs, 0.001, 'BNUM',b);

    %stop recording
    pause(1);
    NetStation('StopRecording');

    fprintf('Saving block data.\n');
    save(datafile, 'sweepdata','respdata','resptime');
    if pausefor(15)
        break
    end
end

%% finish up
fprintf('\n');

fprintf('Finishing up.\n');

if ~exist('DEBUG','var') || DEBUG == 0
    if srboxporth ~= 0
        %close srbox port
        CMUBox('Close', srboxporth);
    end
    
    %close goggles port
    clear io32
    
    %close audio device
    PsychPortAudio('Close',pahandle);
end
fprintf('DONE! Run took %.1f minutes.\n', toc(tStart) / 60);