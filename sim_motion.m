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
mu_s = G*SM;
Re = 6378;

global maint dvTime ref_r ref_i dv_sum dvMag dvType dv_count last_burn avg_rs avg_is;
maint = 0; %enable to maintain the equatorial circular orbit around the Moon
dvTime = [];
dvMag = [];
dvType = [];
ref_r = 1500 + MR; %km
ref_i = 0; %deg
dv_sum = 0;
dv_count = 0;
last_burn = 0;
avg_rs = zeros(1,10);
avg_is = zeros(1,10);

if (maint)
    mt = 'maint';
else
    mt = '';
end

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
%te = 86400*365.25;
dt = 60;
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

Sun_x0 = [-3.015003340678549E+05, -7.470483357006348E+05, -3.058533471913356E+05];
Sun_v0 = [1.149896954751811E-02, 2.725444894760739E-03, 9.238879601343228E-04];
Mercury_x0 = [-4.827024320798659E+07, 1.697930111653017E+07, 1.413503543987976E+07];
Mercury_v0 = [-3.033142419821761E+01, -3.846274558632291E+01, -1.740279799139062E+01];
Venus_x0 = [-1.004569707276745E+08, 3.224402723329408E+07, 2.087559917198319E+07];
Venus_v0 = [-1.277186431031924E+01, -3.023276010352786E+01, -1.279545648223258E+01];
Earth_x0 = [-5.174835915958109E+07, -1.316599595386622E+08, ...
    -5.705344204382185E+07]; %rel to SS Barycenter, km
Earth_v0 = [2.753949833584044E+01, -9.367369771530978E+00, ...
    -4.061277442160828E+00]; %SS Barycenter, km/s
Moon_x0 = [-5.183876277003976E+07, -1.320084193467754E+08, ...
    -5.724192600722729E+07]; 
Moon_v0 = [2.848553293976430E+01, -9.577191588045794E+00, ...
    -4.130371703633702E+00];
Mars_x0 = [2.007287970715508E+08, 6.002347977124631E+07, 2.214617678644839E+07];
Mars_v0 = [-6.480750929219268E+00, 2.279140789774858E+01, 1.062867588252379E+01];
Jupiter_x0 = [-4.098222265470107E+08, 6.141039396221642E+08, 2.732044843852877E+08];
Jupiter_v0 = [-1.130964771399676E+01, -5.786076145670687E+00, -2.204677105188003E+00];
Saturn_x0 = [1.405944606817885E+09, 1.730548974355383E+08, 1.092346360136328E+07];
Saturn_v0 = [-1.644092998791448E+00, 8.825393133369433E+00, 3.715570769861225E+00];
Uranus_x0 = [1.399714070021688E+09, 2.345006614762942E+09, 1.007251382334367E+09];
Uranus_v0 = [-6.021071169932810E+00, 2.677844281306985E+00, 1.258042487010688E+00];
Neptune_x0 = [4.466094765331440E+09, 1.780455669690870E+08, -3.831483375880877E+07];
Neptune_v0 = [-2.151376876037164E-01, 5.056825836277882E+00, 2.074789183973950E+00];

r = ref_r;
v = sqrt(mu_m/r);
Sat_peri_r = [r,0,0]';
Sat_peri_v = [0,v,0]';
hm = cross(Moon_x0,Moon_v0);
mid = acos(dot(hm,[0,0,1])/norm(hm))*180/pi;
Op_g = peri2geo(0,mid,0);
Sat_J2000 = Op_g*Sat_peri_r;
Sat_J2000_v = Op_g*Sat_peri_v; 
T = 2*pi*r^1.5/sqrt(mu_m);

%Format: [Sat, Sun, Mercury, Venus, Earth, Moon, Mars, Jupiter, Saturn, Uranus, Neptune]

Sat_x0 = Sat_J2000'+Moon_x0;
Sat_v0 = Sat_J2000_v'+Moon_v0;
x0 = [Sat_x0';Sun_x0';Mercury_x0';Venus_x0';Earth_x0';Moon_x0';Mars_x0';...
    Jupiter_x0';Saturn_x0';Uranus_x0';Neptune_x0';];
v0 = [Sat_v0';Sun_v0';Mercury_v0';Venus_v0';Earth_v0';Moon_v0';Mars_v0';...
    Jupiter_v0';Saturn_v0';Uranus_v0';Neptune_v0'];
X0 = [x0;v0;];
[T_J,E_J] = ode_helper(@grav_J,0,te,dt,X0,options);

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
fname = sprintf('Plots/%s_all_planets_%i.png',mt,round(te/86400));
print(fname,'-dpng');

figure;
hold on; axis equal;
%plot3(Earth_X(:,1)-Sun_X(:,1),Earth_X(:,2)-Sun_X(:,2),Earth_X(:,3)-Sun_X(:,3),...
%'b','DisplayName','Earth','LineWidth',2);
plot3(Moon_X(:,1)-Earth_X(:,1),Moon_X(:,2)-Earth_X(:,2),Moon_X(:,3)-Earth_X(:,3)...
    ,'color',gray./norm(gray),'DisplayName','Moon','LineWidth',2);
plot3(Sat_X(:,1)-Earth_X(:,1),Sat_X(:,2)-Earth_X(:,2),Sat_X(:,3)-Earth_X(:,3)...
    ,'m','DisplayName','DSG');
[XS, YS, ZS] = sphere(30); % plot the Earth using Matlab sphere command
hold on;
h = surf(XS*Re, YS*Re, ZS*Re,'DisplayName','Earth');
legend('location','Northeast');
fname = sprintf('Plots/%s_earth_moon_dsg_%i.png',mt,round(te/86400));
print(fname,'-dpng');

figure;
hold on; axis equal;
plot3(Sat_X(:,1)-Moon_X(:,1),Sat_X(:,2)-Moon_X(:,2),Sat_X(:,3)-Moon_X(:,3));
[XS, YS, ZS] = sphere(30); % plot the Earth using Matlab sphere command
hold on;
h = surf(XS*MR, YS*MR, ZS*MR);
rotate(h,[1,0,0],-mid);
view(0,125);
fname = sprintf('Plots/%s_dsg_moon_top_%i.png',mt,round(te/86400));
print(fname,'-dpng');
view(0,20);
fname = sprintf('Plots/%s_dsg_moon_front_%i.png',mt,round(te/86400));
print(fname,'-dpng');
view(3);
fname = sprintf('Plots/%s_dsg_moon_3d_%i.png',mt,round(te/86400));
print(fname,'-dpng');

rs = zeros(1,length(Sat_X));
is = zeros(1,length(Sat_X));
es = zeros(1,length(Sat_X));
mis = zeros(1,length(Sat_X));
vs = zeros(1,length(Sat_V));
for k = 1:length(Sat_X)
    r = Sat_X(k,:) - Moon_X(k,:);
    v = Sat_V(k,:) - Moon_V(k,:);
    vs(k) = norm(v);
    rs(k) = norm(r)-MR;
    
    h = cross(r,v);
    e = cross(v,h)./mu_m - r./norm(r);
    es(k) = norm(e);
    
    si = acos(dot(h,[0,0,1])/norm(h))*180/pi;
    hm = cross(Moon_X(k,:),Moon_V(k,:));
    mi = acos(dot(hm,[0,0,1])/norm(hm))*180/pi;
    is(k) = si-mi;
end

figure;
subplot(4,1,1);
plot(T_J./86400,rs);
xlabel('Time (days)');
ylabel('Altitude (km)');

subplot(4,1,2);
plot(T_J./86400,es);
xlabel('Time (days)');
ylabel('Eccentricity');

subplot(4,1,3);
plot(T_J./86400,is);
xlabel('Time (days)');
ylabel('Inclination (deg)');

subplot(4,1,4);
plot(T_J./86400,vs);
xlabel('Time (days)');
ylabel('Velocity (km/s)');
fname = sprintf('Plots/%s_r_e_i_v_%i.png',mt,round(te/86400));
print(fname,'-dpng');

tofs = linspace(3*86400,10*86400,20);
times = 1:2880:length(T_J);
[X,Y] = meshgrid(T_J(times),tofs);
%Define circular parking orbit, 200 km altitude
ri = Re + 200;
vi = sqrt(mu_e/ri);
ri_p = [ri,0,0]';
vi_p = [0,vi,0]';
Op_g = peri2geo(0,0,0);
ri_J = Op_g*ri_p;
vi_p = Op_g*vi_p;

satdvs = zeros(size(Y));
for k = 1:size(X,2)
    for j = 1:size(Y,1)
        %Calculate Earth to DSG delta-V
        %fprintf('%i: Solving lambert prob with tof %.3f\n',k,tofs(j));
        indx = times(k);
        rdsg = Sat_X(indx,:) - Earth_X(indx,:);
        sv = Sat_V(indx,:) - Earth_V(indx,:);
        [Vi,Vf] = lambertProblemBasicSolution(mu_e,ri_J',rdsg,Y(j));
        satdvs(j,k) = abs(norm(Vi) - norm(vi_p)) + abs(norm(Vf) - norm(sv));
    end
end

tofs = linspace(0.5*365.25*86400,1.5*365.25*86400,100);
times = 1:2880:length(T_J);
[X2,Y2] = meshgrid(T_J(times),tofs);
emdvs = zeros(size(Y2));
mmdvs = zeros(size(Y2));
for k = 1:size(X2,2)
    for j = 1:size(Y2,1)
        indx = times(k);
        rdsg = Sat_X(indx,:);
        sv = Sat_V(indx,:);
        
        ris = ri_J' + Earth_X(indx,:);
        vis = vi_p' + Earth_V(indx,:);
        
        [emVi,emVf] = lambertProblemBasicSolution(mu_s,ris,Mars_X(indx,:),Y2(j));
        emdv = abs(norm(emVi)-norm(vis)) + abs(norm(emVf)-norm(Mars_V(indx,:)));
        
        [mmVi,mmVf] = lambertProblemBasicSolution(mu_s,Sat_X(indx,:),Mars_X(indx,:),Y2(j));
        mmdv = abs(norm(mmVi)-norm(Sat_V(indx,:))) + abs(norm(mmVf)-norm(Mars_V(indx,:)));
        
        emdvs(j,k) = emdv;
        mmdvs(j,k) = mmdv;
    end
end

figure;
contourf(X./86400,Y./86400,satdvs);
c = colorbar;
c.Label.String = 'Delta-V (km/s)';
xlabel('Simulation Time (days)');
ylabel('Transfer Time (days)');
title('Earth to DSG Transfer');
fname = sprintf('Plots/%s_earth_dsg_dv_%i.png',mt,round(te/86400));
print(fname,'-dpng');

figure;
contourf(X2./86400,Y2./86400,emdvs);
c = colorbar;c.Label.String = 'Delta-V (km/s)';
xlabel('Simulation Time (days)');
ylabel('Transfer Time (days)');
title('Earth to Mars Transfer');
fname = sprintf('Plots/%s_earth_Mars_dv_%i.png',mt,round(te/86400));
print(fname,'-dpng');

figure;
contourf(X2./86400,Y2./86400,mmdvs);
c = colorbar;c.Label.String = 'Delta-V (km/s)';
xlabel('Simulation Time (days)');
ylabel('Transfer Time (days)');
title('DSG to Mars Transfer');
fname = sprintf('Plots/%s_dsg_Mars_dv_%i.png',mt,round(te/86400));
print(fname,'-dpng');

figure;
contourf(X2./86400,Y2./86400,mmdvs-emdvs);
c = colorbar;c.Label.String = 'Delta-V (km/s)';
xlabel('Simulation Time (days)');
ylabel('Transfer Time (days)');
title('Delta-V Savings on Transfer from DSG to Mars vs. Earth to Mars');
fname = sprintf('Plots/%s_diff_dvs_%i.png',mt,round(te/86400));
print(fname,'-dpng');


%% Functions
function [T,X] = ode_helper(handle,start_time,stop_time,dt,X0g,options)
global maint dvTime dvMag dvType dv_sum dv_count;
T = [];
X = [];
if (maint)
    tend = stop_time;
    t_sim = 0;
    
    per10 = (stop_time - start_time)/5;
    init_tspan = start_time:dt:per10;
    [tio,Xio] = ode45(handle,init_tspan,X0g,options);
    while (t_sim < tend)
        if (isempty(dvTime))
            if (isempty(T) || T(end) < tio(end))
                T = [T;tio];
                X = [X;Xio];
                t_sim = tio(end);
            end
            
            if ((tend-t_sim)/tend < 0.1)
                sim_end = tend;
                n = (sim_end-t_sim)/dt+1;
                if (n < 2)
                    break;
                end
            else
                sim_end = t_sim+per10;
                n = (sim_end-t_sim)/dt+1;
            end
            %fprintf('empty t_sim %.3f tio_end: %.3f end: %.3f\n',t_sim,tio(end),sim_end);
%             if (~isempty(T))
%                 fprintf('T end %.3f\n',T(end));
%             end
            tspan = linspace(t_sim,sim_end,n);
            X0 = X(end,:);
            [tio,Xio] = ode45(handle,tspan,X0,options);
        else
            while (~isempty(dvTime))
                %Sim up to burn
                nbt = dvTime(1);
                if (nbt == t_sim)
                    dvTime = [];
                    dvMag = [];
                    dvType = [];
                    continue;
                end
                
                n = (nbt-t_sim)/dt+1;
                tspan = linspace(t_sim,nbt,n);
                if (isempty(X))
                    X0 = X0g;
                else
                    X0 = X(end,:);
                end
                
                %fprintf('BURN t_sim %.3f tio_end: %.3f nbt: %.3f\n',t_sim,tio(end),nbt);
%                 if (~isempty(T))
%                     fprintf('T end %.3f\n',T(end));
%                 end
                [tio,Xio] = ode45(handle,tspan,X0,options);
                T = [T;tio];
                X = [X;Xio];
                t_sim = tio(end);
                
                type = dvType(1);
                if (type == 'r')
                    %Apply burn
                    %fprintf('Burned at %.3f\n',t_sim);
                    Sat_v = getv(X(end,:),'Sat','v');
                    Moon_v = getv(X(end,:),'Moon','v');
                    v = Sat_v - Moon_v;
                    dv_mag = dvMag(1);
                    dv = dv_mag.*v./norm(v);
                    Sat_v = Sat_v + dv;
                    X(end,34:36) = Sat_v;
                elseif (type == 'i')
                    r = getv(X(end,:),'Sat','r') - getv(X(end,:),'Moon','r');
                    v = getv(X(end,:),'Sat','v') - getv(X(end,:),'Moon','v');
                    h = cross(r,v);
                    
                    dv_mag = dvMag(1);
                    dv = -dv_mag.*h./norm(h);
                    Sat_v = getv(X(end,:),'Sat','v') + dv;
                    X(end,34:36) = Sat_v;
                end
                
                %Remove burn
                dvTime(1) = [];
                dvMag(1) = [];
                dvType(1) = [];
                last_burn = t_sim;
                dv_sum = dv_sum + dv_mag;
                dv_count = dv_count +1;
            end
        end
    end
else
    n = (stop_time-start_time)/dt+1;
    gtspan = linspace(start_time,stop_time,n);
    [T,X] = ode45(handle,gtspan,X0g,options);
end
end

function Xdot = grav_J(t,x)
global PM mu_e Fx Fy Fz Re J_E J_M MR mu_m;
global maint dvTime dvMag ref_r ref_i last_burn avg_rs avg_is dvType;

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
xp = ESR(1);
y = ESR(2);
z = ESR(3);
rn = norm(ESR);
Sat_grav_je = [Fx(J2_E,J3_E,J4_E,J5_E,Re,mu_e,rn,xp,y,z),...
    Fy(J2_E,J3_E,J4_E,J5_E,Re,mu_e,rn,xp,y,z), ...
    Fz(J2_E,J3_E,J4_E,J5_E,Re,mu_e,rn,xp,y,z)]; %j perturbing forces from Earth
Sat_grav_jm = [Fx(J2_M,J3_M,J4_M,J5_M,MR,mu_m,rn,xp,y,z),...
    Fy(J2_M,J3_M,J4_M,J5_M,MR,mu_m,rn,xp,y,z),...
    Fz(J2_M,J3_M,J4_M,J5_M,MR,mu_m,rn,xp,y,z)];
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

if (maint)
    r = Sat_X - Moon_X;
    v = getv(x,'Sat','v') - getv(x,'Moon','v');
    h = cross(r,v);
    
    si = acos(dot(h,[0,0,1])/norm(h))*180/pi;
    hm = cross(Moon_X,getv(x,'Moon','v'));
    mi = acos(dot(hm,[0,0,1])/norm(hm))*180/pi;
    i = si - mi; %deg
    
    [dec,~] = r_to_angles(r);
    dec = dec*180./pi; %deg
    
    avg_rs(1) = [];
    avg_rs(10) = norm(r);
    
    avg_is(1) = [];
    avg_is(10) = i;
    rn = norm(r);
    if (mean(avg_rs) < ref_r - 2 && isempty(dvTime) && t-last_burn > 300) %need to boost the radius
        ra = ref_r+1;
        a = (rn + ra)/2;
        vp = sqrt(2*mu_m/rn - mu_m/a);
        va = sqrt(2*mu_m/ra - mu_m/a);
        
        dv1 = vp - sqrt(mu_m/rn);
        dv2 = (sqrt(mu_m/ra) - va);
        T = pi*a^1.5/sqrt(mu_m);
        
        %Store dv1 and dv2
        dvTime = [t,t+T];
        dvMag = [dv1,dv2];
        dvType = ['r','r'];
        fprintf('Burn 1 at %.3f and Burn 2 at %.3f\n',t./86400,(t+T)./86400);
    elseif (mean(avg_is) > 0.5 && isempty(dvTime) && t-last_burn > 300 ...
            && dec < 0.01 && dec > -0.01) 
        dv = 2*norm(v)*sind(i/2);
        
        e = cross(v,h)./mu_m - r./norm(r);
        P = norm(h)^2./mu_m;
        ra = P./(1-norm(e));
        a = ra./(1+norm(e));
        T = pi*a^1.5/sqrt(mu_m);
        
        dvTime = [t,t+T];
        dvMag = [dv/2,-dv/2];
        dvType = ['i','i'];
        fprintf('Inc Burn at %.3f and %.3f\n',t./86400,(t+T)./86400);
    end
end
end