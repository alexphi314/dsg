%% Alex Philpott
clear;
close all;

%Initial conditions
global rho mu_m;
EM = 5.972e24; %kg
MM = 7.348e22; %kg
EMR = 384399; %km
ER = 6378; %km
MR = 1737.1; %km
D = EMR;
G = 6.671e-11/1000^3; %km/kg-s2
n = sqrt(G*(EM+MM)/D^3);
gray = [128,139,150];

rho = 0.01215;
X0_CR = [0.5-rho,sqrt(3)/2,0,0,0,0];

%% CR3BP
N = 1000;
te = 86400*30;
tspan = linspace(0,n*te,N);
options = odeset('AbsTol',1e-9,'RelTol',1e-7);
[T_CR3BP, X_CR3BP] = ode45(@grav_CR3BP,tspan,X0_CR,options);

figure;
hold on; axis equal;
circle(-rho,0,ER/D,'b','Earth');
circle(1-rho,0,MR/D,gray/norm(gray),'Moon');
plot(X_CR3BP(:,1),X_CR3BP(:,2),'DisplayName','DSG');
legend('location','Northeast');

%% Inertial Frame
%Assume starting time is 2026-06-01
%J2000 reference frame

Earth_x0 = [-5.174835915958109E+07, -1.316599595386622E+08, ...
    -5.705344204382185E+07]; %rel to SS Barycenter, km
Earth_v0 = [2.753949833584044E+01, -9.367369771530978E+00, ...
    -4.061277442160828E+00]; %SS Barycenter, km/s
Moon_x0 = [-5.183876277003976E+07, -1.320084193467754E+08, ...
    -5.724192600722729E+07]; 
Moon_v0 = [2.848553293976430E+01, -9.577191588045794E+00, ...
    -4.130371703633702E+00];
EMB_x0 = [-5.174945761626828E+07, -1.316641935289254E+08, ...
    -5.705573223410274E+07];
EMB_v0 = [2.755099320901770E+01, -9.369919229194213E+00, ...
    -4.062116977807424E+00];

Earth_x0 = Earth_x0 - EMB_x0;
Earth_v0 = Earth_v0 - EMB_v0;
Moon_x0 = Moon_x0 - EMB_x0;
Moon_v0 = Moon_v0 - EMB_v0;

%Format: [Sat, Earth, Moon]
mu_m = G*MM;
r = 1500+MR;
v = sqrt(mu_m/r);
Sat_J2000 = [r,0,0]';
Sat_J2000_v = [0,v,0]';
% T = 2*pi*r^1.5/sqrt(mu_m);
% 
% tspan = linspace(0,15*T,N);
% [T_2BP,X_2BP] = ode45(@grav_2BP,tspan,[Sat_J2000;Sat_J2000_v],options);
% 
% figure; 
% hold on; axis equal;
% circle(0,0,r,'g','Reference Orbit');
% plot(X_2BP(:,1),X_2BP(:,2),'DisplayName','Orbit');
% circle(0,0,MR,gray/norm(gray),'moon');
% 
% Es = zeros(1,length(X_2BP));
% hs = zeros(1,length(X_2BP));
% for k = 1:length(X_2BP)
%     r = X_2BP(k,1:3);
%     v = X_2BP(k,4:6);
%     
%     E = norm(v)^2/2 - mu_m/norm(r);
%     h = norm(cross(r,v));
%     
%     Es(k) = E;
%     hs(k) = h;
% end
% 
% figure;
% plot(T_2BP,Es);

Sat_x0 = Sat_J2000'+Moon_x0;
Sat_v0 = Sat_J2000_v'+Moon_v0;
x0_J = [Sat_x0';Sat_v0';Earth_x0';Earth_v0';Moon_x0';Moon_v0'];
tspan = linspace(0,te,te/60);
[T_J,E_J] = ode45(@grav_J,tspan,x0_J,options);

Sat_X = E_J(:,1:3);
Sat_V = E_J(:,4:6);
Earth_X = E_J(:,7:9);
Earth_V = E_J(:,10:12);
Moon_X = E_J(:,13:15);
Moon_V = E_J(:,16:18);

figure;
hold on; axis equal;
plot3(Earth_X(:,1),Earth_X(:,2),Earth_X(:,3),'b','DisplayName','Earth','LineWidth',2);
plot3(Moon_X(:,1),Moon_X(:,2),Moon_X(:,3),'color',gray./norm(gray),'DisplayName','Moon','LineWidth',2);
plot3(Sat_X(:,1),Sat_X(:,2),Sat_X(:,3),'m','DisplayName','DSG');
legend('location','Northeast');

figure;
hold on; axis equal;
plot3(Sat_X(:,1)-Moon_X(:,1),Sat_X(:,2)-Moon_X(:,2),Sat_X(:,3)-Moon_X(:,3));

%% Functions

function Xdot = grav_CR3BP(~,X)
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

function Xdot = grav_J(~,x)
Xdot = zeros(18,1);
x = x';
EM = 5.972e24; %kg
MM = 7.348e22; %kg
Sat_Mass = 0.5*419725; %kg, half mass of ISS

Sat = x(1:6);
Earth = x(7:12);
Moon = x(13:18);

Sat_pos = Sat(1:3);
Earth_pos = Earth(1:3);
Moon_pos = Moon(1:3);

X = [Sat_pos;Earth_pos;Moon_pos];
M = [Sat_Mass,EM,MM];
a = calc_accel(M,X);

Xdot(1:3) = Sat(4:6);
Xdot(4:6) = a(1,:);

Xdot(7:9) = Earth(4:6);
Xdot(10:12) = a(2,:);

Xdot(13:15) = Moon(4:6);
Xdot(16:18) = a(3,:);
end

function Xdot = grav_2BP(~,x)
global mu_m;
mu = mu_m;

Xdot(1:3) = x(4:6);
r = x(1:3);
rn = norm(r);

Xdot(4:6) = -mu/rn^3*r;
Xdot = Xdot';
end

function p = circle(x0,y0,r,color,label)
% Plots circle with radius r located at x0, y0
% Call: circle(x0,y0,r)
hold on;
th = linspace(0,2*pi,100);
xp = x0 + r*cos(th);
yp = y0 + r*sin(th);
p = plot(xp,yp,'color',color,'DisplayName',label,'LineWidth',2);
end