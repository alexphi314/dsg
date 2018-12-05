function out = getv(x,plan,type)
% get_r(x,num)
% Given vector x and number in matrix, return radius vector

switch plan
    case 'Sun'
        n = 2;
    case 'Mercury'
        n = 3;
    case 'Venus'
        n = 4;
    case 'Earth'
        n = 5;
    case 'Moon'
        n = 6;
    case 'Mars'
        n = 7;
    case 'Jupiter'
        n = 8;
    case 'Saturn'
        n = 9;
    case 'Uranus'
        n = 10;
    case 'Neptune'
        n = 11;
    case 'Sat'
        n = 1;
end

if type == 'v'
    n = n + 11;
end

lower = 3*n-2;
upper = 3*n;
out = x(:,lower:upper);
end