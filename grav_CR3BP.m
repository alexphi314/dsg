function Xdot = grav_CR3BP(~,X)
%Acceleration due to gravity in CR3BP
%For use with ode45
global rho;

x = X(1);
y = X(2);
z = X(3);
xd = X(4);
yd = X(5);

r1 = sqrt((x+rho)^2+y^2+z^2);
r2 = sqrt((x-1+rho)^2+y^2+z^2);

Xdot(1:3) = X(4:6);
Xdot(4) = 2*yd + x - (1-rho)*(x+rho)/r1^3 - rho*(x-1+rho)/r2^3;
Xdot(5) = y - 2*xd - (1-rho)*y/r1^3 - rho*y/r2^3;
Xdot(6) = -(1-rho)*z/r1^3 - rho*z/r2^3;
Xdot = Xdot';
end