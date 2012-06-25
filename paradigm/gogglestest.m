function gogglestest

gogglesport = '378';
portaddr = hex2dec(gogglesport);
    
while true
    fprintf('opening parallel port %s.\n', gogglesport);
    
    gogglesportobj = io32;
    portstatus = io32(gogglesportobj);
    
    if portstatus ~= 0
        fprintf('Could not open port.');
        return;
    end
    
    %initialise goggles and set up mode
    visual_state = 0;
    fprintf('sending %d.\n', visual_state);    
    io32(gogglesportobj,portaddr,visual_state);

    pause(2);
    
    visual_state = 1;
    fprintf('sending %d.\n', visual_state);    
    io32(gogglesportobj,portaddr,visual_state);
    pause(2);
    
    visual_state = 2;
    fprintf('sending %d.\n', visual_state);    
    io32(gogglesportobj,portaddr,visual_state);
    pause(2);
    
    visual_state = 3;
    fprintf('sending %d.\n', visual_state);    
    io32(gogglesportobj,portaddr,visual_state);
    pause(2);
    
    visual_state = 0;
    fprintf('sending %d.\n', visual_state);    
    io32(gogglesportobj,portaddr,visual_state);
    pause(2);

    fprintf('Closing port.\n');
    clear io32
end