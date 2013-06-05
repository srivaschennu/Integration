function playsample(ch,fs,fc,fm,len)

%connect to DMX
InitializePsychSound

if PsychPortAudio('GetOpenDeviceCount') == 1
    PsychPortAudio('Close',0);
end

% audiodevices = PsychPortAudio('GetDevices',2);
% outdevice = strcmp('Microsoft Sound Mapper - Output',{audiodevices.DeviceName});

audiodevices = PsychPortAudio('GetDevices',3);
outdevice = strcmp('DMX 6Fire USB ASIO Driver',{audiodevices.DeviceName});

pahandle = PsychPortAudio('Open',audiodevices(outdevice).DeviceIndex,[],[],fs,2);

if strcmp(ch,'left')
    leftdata = amfm(fs,fc,fm,len);
    rightdata = zeros(fs*len,1);
elseif strcmp(ch,'right')
    leftdata = zeros(fs*len,1);
    rightdata = amfm(fs,fc,fm,len);
end

stimdata = [leftdata rightdata];
PsychPortAudio('FillBuffer',pahandle,stimdata');

PsychPortAudio('Start',pahandle);
starttime = GetSecs;
stoptime = starttime + len;

while GetSecs <= stoptime
end

PsychPortAudio('Close',pahandle);
