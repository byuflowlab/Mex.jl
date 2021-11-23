function interruptions()

% this one requires the ENABLE_INTERRUPTS flag to be set to `true`
% jleval 'global x = 0; while(true); global x += 1; yield(); end'

% this one isn't interruptable, as it never yields
% jleval 'global x = 0; while(true); global x += 1; end'

end