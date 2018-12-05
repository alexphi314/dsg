function P = legendre(n,m)
% legendre(n,m), n is the degree of the legendre, order is m
% Returns the function handle P that takes an argument

syms u;
func = (u^2-1)^n;
Pn = diff(func,n)/2^n/factorial(n);
Pnm = (1-u^2)^(m/2)*diff(Pn,m);
P = matlabFunction(simplify(Pnm));
end