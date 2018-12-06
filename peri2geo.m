function Op_g = peri2geo(O,i,w)
% Op_g = peri2geo(O,i,w)
%        O -> starting RAAN in deg
%        i -> starting inclination in deg
%        w -> starting arg of periapsis in deg
% Generates DCM from perifocal coordinate frame to geocentric coordinate
% frame
Oo = O;
io = i;
wo = w;
Op_g = [-sind(Oo).*cosd(io).*sind(wo) + cosd(Oo).*cosd(wo), cosd(Oo).*cosd(io).*sind(wo) + sind(Oo).*cosd(wo), sind(io).*sind(wo);
    -sind(Oo).*cosd(io).*cosd(wo) - cosd(Oo).*sind(wo), cosd(Oo).*cosd(io).*cosd(wo) - sind(Oo).*sind(wo), sind(io).*cosd(wo);
    sind(Oo).*sind(io), -cosd(Oo).*sind(io), cosd(io)];
end