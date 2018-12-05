%% Alex Philpott
clear;
close all;

%Initial conditions
global rho mu_m PM Re mu_e J_E J_M Fx Fy Fz MR;
% Planet Masses
SM = 1.989e30;
MerM = 330.2e21;
VM = 4.869e24;
EM = 5.972e24; %kg
MM = 7.348e22; %kg
MarM = 641.9e21;
JM = 1.899e27;
SatrM = 568.5e24;
UM = 86.83e24;
NM = 102.4e24;
Sat_Mass = 0.5*419725; %kg, half mass of ISS
PM = [Sat_Mass,SM,MerM,VM,EM,MM,MarM,JM,SatrM,UM,NM];

EMR = 384399; %km
ER = 6378; %km
MR = 1738; %km
D = EMR;
G = 6.671e-11/1000^3; %km/kg-s2
n = sqrt(G*(EM+MM)/D^3);
gray = [128,139,150];
mu_e = G*EM;
mu_m = 4902.80011526323;
Re = 6378;
J2_E  = 0.10826360229840e-02;
J3_E = -0.25324353457544e-05;
J4_E = -0.16193312050719e-05;
J5_E = -0.22771610163688e-06;
J_E = [J2_E,J3_E,J4_E,J5_E];
J2_M = 9.0884339347424299e-05;
J3_M = 3.1973308084610398e-06;
J4_M = -3.2347808442570100e-06;
J5_M = 2.2378531356778999e-07;
J_M = [J2_M,J3_M,J4_M,J5_M];

N = 1000;
te = 86400*180;
options = odeset('AbsTol',1e-9,'RelTol',1e-7);

syms mu x y z r Rs J2s J3s J4s J5s;
r_eqn = (x^2 + y^2 + z^2)^0.5;
%U = mu*Res^2/(2*r^3)*J2s*(3*(z/r)^2 - 1) +... 
%       mu*J3s*Res^3/(2*r^4)*( 5*(z/r)^3 - 3*(z/r) );
p2 = legendre(2,0);
p3 = legendre(3,0);
p4 = legendre(4,0);
p5 = legendre(5,0);
U = -mu/r*(-J2s*Rs^2/r^2*p2(z/r) - J3s*Rs^3/r^3*p3(z/r) - J4s*Rs^4/r^4*p4(z/r) - J5s*Rs^5/r^5*p5(z/r));
Ux = -(diff(U,r)*diff(r_eqn,x));
Uy = -(diff(U,r)*diff(r_eqn,y));
Uz = -(diff(U,r)*diff(r_eqn,z) + diff(U,z));

Fx = matlabFunction(Ux);
Fy = matlabFunction(Uy);
Fz = matlabFunction(Uz);

%% Inertial Frame
%Assume starting time is 2026-06-01
%J2000 reference frame
%From JPL Horizons
EMB_x0 = [-5.174945761626828E+07, -1.316641935289254E+08, ...
    -5.705573223410274E+07];
EMB_v0 = [2.755099320901770E+01, -9.369919229194213E+00, ...
    -4.062116977807424E+00];

Sun_x0 = [-3.015003340678549E+05, -7.470483357006348E+05, -3.058533471913356E+05] - EMB_x0;
Sun_v0 = [1.149896954751811E-02, 2.725444894760739E-03, 9.238879601343228E-04] - EMB_v0;
Mercury_x0 = [-4.827024320798659E+07, 1.697930111653017E+07, 1.413503543987976E+07] - EMB_x0;
Mercury_v0 = [-3.033142419821761E+01, -3.846274558632291E+01, -1.740279799139062E+01] - EMB_v0;
Venus_x0 = [-1.004569707276745E+08, 3.224402723329408E+07, 2.087559917198319E+07] - EMB_x0;
Venus_v0 = [-1.277186431031924E+01, -3.023276010352786E+01, -1.279545648223258E+01] - EMB_v0;
Earth_x0 = [-5.174835915958109E+07, -1.316599595386622E+08, ...
    -5.705344204382185E+07] - EMB_x0; %rel to SS Barycenter, km
Earth_v0 = [2.753949833584044E+01, -9.367369771530978E+00, ...
    -4.061277442160828E+00] - EMB_v0; %SS Barycenter, km/s
Moon_x0 = [-5.183876277003976E+07, -1.320084193467754E+08, ...
    -5.724192600722729E+07] - EMB_x0; 
Moon_v0 = [2.848553293976430E+01, -9.577191588045794E+00, ...
    -4.130371703633702E+00] - EMB_v0;
Mars_x0 = [2.007287970715508E+08, 6.002347977124631E+07, 2.214617678644839E+07] - EMB_x0;
Mars_v0 = [-6.480750929219268E+00, 2.279140789774858E+01, 1.062867588252379E+01] - EMB_v0;
Jupiter_x0 = [-4.098222265470107E+08, 6.141039396221642E+08, 2.732044843852877E+08] - EMB_x0;
Jupiter_v0 = [-1.130964771399676E+01, -5.786076145670687E+00, -2.204677105188003E+00] - EMB_v0;
Saturn_x0 = [1.405944606817885E+09, 1.730548974355383E+08, 1.092346360136328E+07] - EMB_x0;
Saturn_v0 = [-1.644092998791448E+00, 8.825393133369433E+00, 3.715570769861225E+00] - EMB_v0;
Uranus_x0 = [1.399714070021688E+09, 2.345006614762942E+09, 1.007251382334367E+09] - EMB_x0;
Uranus_v0 = [-6.021071169932810E+00, 2.677844281306985E+00, 1.258042487010688E+00] - EMB_v0;
Neptune_x0 = [4.466094765331440E+09, 1.780455669690870E+08, -3.831483375880877E+07] - EMB_x0;
Neptune_v0 = [-2.151376876037164E-01, 5.056825836277882E+00, 2.074789183973950E+00] - EMB_v0;

r = 1500+MR;
v = sqrt(mu_m/r);
Sat_J2000 = [r,0,0]';
Sat_J2000_v = [0,v,0]'; 
T = 2*pi*r^1.5/sqrt(mu_m);

%Format: [Sat, Sun, Mercury, Venus, Earth, Moon, Mars, Jupiter, Saturn, Uranus, Neptune]

Sat_x0 = Sat_J2000'+Moon_x0;
Sat_v0 = Sat_J2000_v'+Moon_v0;
x0 = [Sat_x0';Sun_x0';Mercury_x0';Venus_x0';Earth_x0';Moon_x0';Mars_x0';...
    Jupiter_x0';Saturn_x0';Uranus_x0';Neptune_x0';];
v0 = [Sat_v0';Sun_v0';Mercury_v0';Venus_v0';Earth_v0';Moon_v0';Mars_v0';...
    Jupiter_v0';Saturn_v0';Uranus_v0';Neptune_v0'];
X0 = [x0;v0;];
tspan = linspace(0,te,te/60);
[T_J,E_J] = ode45(@grav_J,tspan,X0,options);

Sat_X = getv(E_J,'Sat','r');
Sun_X = getv(E_J,'Sun','r');
Mercury_X = getv(E_J,'Mercury','r');
Venus_X = getv(E_J,'Venus','r');
Earth_X = getv(E_J,'Earth','r');
Moon_X = getv(E_J,'Moon','r');
Mars_X = getv(E_J,'Mars','r');
Jupiter_X = getv(E_J,'Jupiter','r');
Saturn_X = getv(E_J,'Saturn','r');
Uranus_X = getv(E_J,'Uranus','r');
Neptune_X = getv(E_J,'Neptune','r');
Sat_V = getv(E_J,'Sat','v');
Sun_V = getv(E_J,'Sun','v');
Mercury_V = getv(E_J,'Mercury','v');
Venus_V = getv(E_J,'Venus','v');
Earth_V = getv(E_J,'Earth','v');
Moon_V = getv(E_J,'Moon','v');
Mars_V = getv(E_J,'Mars','v');
Jupiter_V = getv(E_J,'Jupiter','v');
Saturn_V = getv(E_J,'Saturn','v');
Uranus_V = getv(E_J,'Uranus','v');
Neptune_V = getv(E_J,'Neptune','v');

figure;
hold on; axis equal;
plot3(Mercury_X(:,1)-Sun_X(:,1),Mercury_X(:,2)-Sun_X(:,2),Mercury_X(:,3)-Sun_X(:,3),...
    'k','DisplayName','Mercury','LineWidth',2);
plot3(Venus_X(:,1)-Sun_X(:,1),Venus_X(:,2)-Sun_X(:,2),Venus_X(:,3)-Sun_X(:,3),...
    'y','DisplayName','Venus','LineWidth',2);
plot3(Earth_X(:,1)-Sun_X(:,1),Earth_X(:,2)-Sun_X(:,2),Earth_X(:,3)-Sun_X(:,3),...
    'b','DisplayName','Earth','LineWidth',2);
plot3(Moon_X(:,1)-Sun_X(:,1),Moon_X(:,2)-Sun_X(:,2),Moon_X(:,3)-Sun_X(:,3),...
    'color',gray./norm(gray),'DisplayName','Moon','LineWidth',2);
plot3(Sat_X(:,1)-Sun_X(:,1),Sat_X(:,2)-Sun_X(:,2),Sat_X(:,3)-Sun_X(:,3),...
    'm','DisplayName','DSG','LineWidth',2);
plot3(Mars_X(:,1)-Sun_X(:,1),Mars_X(:,2)-Sun_X(:,2),Mars_X(:,3)-Sun_X(:,3),...
    'r','DisplayName','Mars','LineWidth',2);
plot3(Jupiter_X(:,1)-Sun_X(:,1),Jupiter_X(:,2)-Sun_X(:,2),Jupiter_X(:,3)-Sun_X(:,3),...
    'r','DisplayName','Jupiter','LineWidth',2);
plot3(Saturn_X(:,1)-Sun_X(:,1),Saturn_X(:,2)-Sun_X(:,2),Saturn_X(:,3)-Sun_X(:,3),...
    'g','DisplayName','Saturn','LineWidth',2);
plot3(Uranus_X(:,1)-Sun_X(:,1),Uranus_X(:,2)-Sun_X(:,2),Uranus_X(:,3)-Sun_X(:,3),...
    'c','DisplayName','Uranus','LineWidth',2);
plot3(Neptune_X(:,1)-Sun_X(:,1),Neptune_X(:,2)-Sun_X(:,2),Neptune_X(:,3)-Sun_X(:,3),...
    'b','DisplayName','Neptune','LineWidth',2);
legend('location','Northeast');

figure;
hold on; axis equal;
%plot3(Earth_X(:,1)-Sun_X(:,1),Earth_X(:,2)-Sun_X(:,2),Earth_X(:,3)-Sun_X(:,3),...
%'b','DisplayName','Earth','LineWidth',2);
plot3(Moon_X(:,1)-Earth_X(:,1),Moon_X(:,2)-Earth_X(:,2),Moon_X(:,3)-Earth_X(:,3)...
    ,'color',gray./norm(gray),'DisplayName','Moon','LineWidth',2);
plot3(Sat_X(:,1)-Earth_X(:,1),Sat_X(:,2)-Earth_X(:,2),Sat_X(:,3)-Earth_X(:,3)...
    ,'m','DisplayName','DSG');
circle(0,0,ER,'b','Earth');
legend('location','Northeast');

figure;
hold on; axis equal;
plot3(Sat_X(:,1)-Moon_X(:,1),Sat_X(:,2)-Moon_X(:,2),Sat_X(:,3)-Moon_X(:,3));

%% Functions
function Xdot = grav_J(~,x)
global PM mu_e Fx Fy Fz Re J_E J_M MR mu_m;

Xdot = zeros(66,1);
x = x';

Sat_X = getv(x,'Sat','r');
Sun_X = getv(x,'Sun','r');
Mercury_X = getv(x,'Mercury','r');
Venus_X = getv(x,'Venus','r');
Earth_X = getv(x,'Earth','r');
Moon_X = getv(x,'Moon','r');
Mars_X = getv(x,'Mars','r');
Jupiter_X = getv(x,'Jupiter','r');
Saturn_X = getv(x,'Saturn','r');
Uranus_X = getv(x,'Uranus','r');
Neptune_X = getv(x,'Neptune','r');

X = [Sat_X;Sun_X;Mercury_X;Venus_X;Earth_X;Moon_X;Mars_X;Jupiter_X;Saturn_X;...
    Uranus_X;Neptune_X;];
M = PM;
a = calc_accel(M,X);

Xdot(1:33) = x(34:66);

%% J2 and J3 perturbation from Earth
J2_E = J_E(1);
J3_E = J_E(2);
J4_E = J_E(3);
J5_E = J_E(4);
J2_M = J_M(1);
J3_M = J_M(2);
J4_M = J_M(3);
J5_M = J_M(4);
Sat_grav_a = a(1,:); %gravitational accel
ESR = Sat_X - Earth_X;
x = ESR(1);
y = ESR(2);
z = ESR(3);
rn = norm(ESR);
Sat_grav_je = [Fx(J2_E,J3_E,J4_E,J5_E,Re,mu_e,rn,x,y,z),...
    Fy(J2_E,J3_E,J4_E,J5_E,Re,mu_e,rn,x,y,z), ...
    Fz(J2_E,J3_E,J4_E,J5_E,Re,mu_e,rn,x,y,z)]; %j perturbing forces from Earth
Sat_grav_jm = [Fx(J2_M,J3_M,J4_M,J5_M,MR,mu_m,rn,x,y,z),...
    Fy(J2_M,J3_M,J4_M,J5_M,MR,mu_m,rn,x,y,z),...
    Fz(J2_M,J3_M,J4_M,J5_M,MR,mu_m,rn,x,y,z)];
Xdot(34:36) = Sat_grav_a + Sat_grav_je + Sat_grav_jm; %sat
Xdot(37:39) = a(2,:); %sun
Xdot(40:42) = a(3,:); %mercury
Xdot(43:45) = a(4,:); %venus
Xdot(46:48) = a(5,:); %earth
Moon_grav_a = a(6,:); %grav accel
EMR = Moon_X - Earth_X;
Moon_grav_je = [Fx(J2_E,J3_E,J4_E,J5_E,Re,mu_e,norm(EMR),EMR(1),EMR(2),EMR(3)),...
    Fy(J2_E,J3_E,J4_E,J5_E,Re,mu_e,norm(EMR),EMR(1),EMR(2),EMR(3)), ...
    Fz(J2_E,J3_E,J4_E,J5_E,Re,mu_e,norm(EMR),EMR(1),EMR(2),EMR(3))];%j perturbing forces
Xdot(49:51) = Moon_grav_a + Moon_grav_je; %moon
Xdot(52:54) = a(7,:); %mars
Xdot(55:57) = a(8,:); %jupiter
Xdot(58:60) = a(9,:); %saturn
Xdot(61:63) = a(10,:); %uranus
Xdot(64:66) = a(11,:); %neptune
end