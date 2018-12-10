function Xdot = grav_2BP(~,x)
%Acceleration due to gravity in 2BP
global mu_m;
mu = mu_m;

Xdot(1:3) = x(4:6);
r = x(1:3);
rn = norm(r);

Xdot(4:6) = -mu/rn^3*r;
Xdot = Xdot';
end