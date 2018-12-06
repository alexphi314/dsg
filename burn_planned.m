function i = burn_planned(t,dvTable)
% i = burn_planned(t,dvTable)
% If a burn is planned in the future, return 1
% If a burn is not planned in the future, return 0

n = length(dvTable);
if (n == 0)
    i = 0;
    return;
else
    nb = dvTable(end);
    if (t > nb.time)
        i = 0;
    else
        i = 1;
    end
end
end