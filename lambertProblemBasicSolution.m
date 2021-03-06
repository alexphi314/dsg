function [Vi,Vf] = lambertProblemBasicSolution(mui,ri,rf,tof)
% [Vi,Vf] = lambertProblemBasicSolution(mu,ri,rf,tof)
% Return initial required V and final required V
global mu;
mu = mui; 

TOF = tof; % convert days into TOF in sec

[p, Vi, Vf, f, g, fd, gd] = lambert(mu, ri, rf, TOF);

return

% Brute force solver for Lambert problem - written by ilya@umich.edu
function [p, Vi, Vf, f, g, fd, gd] = lambert(mu, Ri, Rf, TOF)
global A muG t ri rf
muG = mu;
t  = TOF;
ri  = norm(Ri); rf = norm(Rf);
q   = dot([0;0;1],cross(Ri,Rf));
phi = acos(dot(Ri,Rf)/(ri*rf)); 
if (q < 0),
    phi=2*pi - phi;
end
A = sqrt(ri*rf/(1-cos(phi)))*sin(phi);
z = bisection(@Fnon, 0.001, 20);
[res, x, y] = Fnon(z);
p = ri*rf*(1 - cos(phi))/y;
f = 1 - y/ri;
g = A*sqrt(y/mu);
gd = 1      - y/rf;
fd = (f*gd  - 1)/g;
Vi = (Rf    - f*Ri)/g;
Vf = (gd*Rf - Ri)/g; 
return;

function [res,x,y] = Fnon(z)
global A muG t ri rf 
[C, S] = stumpff(z,20);
c3 = S; c2 = 0; c1 = A*sqrt(C); c0 = -sqrt(muG)*t;
roots_all  = roots([c3,c2,c1,c0]);
x = roots_all(find(abs(imag(roots_all))<1e-6));
y = C*x^2;
zout = (1- ( sqrt(C)*(ri + rf - y)/A  ))/S;
res = z - zout;
return;

function [C,S]=stumpff(z, n)
C = 0.5;
S = 1/6;
for i=1:1:n,
    C=C+(-1)^i*z^i/factorial(2*(i+1));
    S=S+(-1)^i*z^i/factorial(2*i+3);
end

return

function p = bisection(f,a,b)
if f(a)*f(b)>0
    disp('No Solution Found: Pick different interval [a,b]')
else
    p = (a + b)/2;
    err = abs(f(p));
    while err > 1e-12
        if f(a)*f(p)<0
            b = p;
        else
            a = p;
        end
        p = (a + b)/2;
        err = abs(f(p));
    end
end
return


