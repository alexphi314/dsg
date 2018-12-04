function [a] = calc_accel(M,X)
%Alex Philpott
%Returns acceleration of each body given position and mass of each body
N = length(M);
G = 6.67e-11./1000^3; %km3/kg/s2
a_indv = 0;
a = zeros(N,3);
for i = 1:N
    for j = 1:N
        if j == i
            continue;
        end
        Ri = X(i,:);
        Rj = X(j,:);
        R = Rj - Ri;
        a_indv = G.*M(j).*R./(norm(R)).^3 + a_indv;
    end
    a(i,:) = a_indv;
    a_indv = 0;
end
        