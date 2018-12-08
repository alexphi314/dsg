function [C,S] = import_CS(n)
% [C,S] = import_CS(n)
%         n -> max degree of gravity field
% Return matrix of C coefficients and S coefficients

data = csvread('gggrx_1200a_sha.tab.txt');

p = n+1;
C = zeros(p,p);
S = zeros(p,p);

for k = 2:size(data,1)
    n = data(k,1);
    m = data(k,2);
    
    if n == p
        break
    end
    
    Cnm = data(k,3);
    Snm = data(k,4);
    
    C(n+1,m+1) = Cnm;
    S(n+1,m+1) = Snm;
end