function EEG = changeref(EEG,refchannels,badchannels)

% [~, badchannels] = findbadtrialschannels(P_C);
% chanlocs = [P_C.XPosition' P_C.YPosition' P_C.ZPosition'];

%local average reference (laplacian operator)
% P_C.Data = lar(P_C.Data,chanlocs,badchannels);

%common average reference
% Data = permute(P_C.Data,[3 2 1]);
% Data = reref(Data,[],'exclude',badchannels);
% P_C.Data = permute(Data,[3 2 1]);

%linked mastoid reference
% if ~isempty(refchannels)
%     if EEG.nbchan == 129
%         mastoidchannels = refchannels57;%[57 100];
%     elseif EEG.nbchan == 257
%         mastoidchannels = [94 190];
%     end
% end

