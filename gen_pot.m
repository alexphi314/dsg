function U = gen_pot(C,S,p)
% U = gen_pot(p)
%     C,S -> matrix of C and S coefficient values
%     p -> max degree of gravity field
%     U -> symbolic expression for potential
%          in terms of x y z Rs r mu
%          Spherical Harmonic expansion for potential

syms x y z Rs r mu;
U = 0;
for n = 1:p
    for m = 0:n
        Pnm = legendre(n,m);
        Cnm = C(n+1,m+1);
        Snm = S(n+1,m+1);
        lamb = atan2(y,x);
        
        term = Rs^n/r^n*Pnm(z/r)*(Cnm*cos(m*lamb)+Snm*sin(m*lamb));
        U = U + term;
    end
end
U = -mu/r*U;
end