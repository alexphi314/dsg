function i = burn_executed(t,dvBurned)
% i = burn_executed(t,dvBurned)
% Return true if the burn has already been executed
% Return false otherwise

if (isempty(dvBurned))
    i = 0;
    return;
else
    lb = dvBurned(end);
    if (t > lb.time)
        i = 0;
    else
        i = 1;
    end
end
end