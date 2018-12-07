function [dec, RA] = r_to_angles(r)
    %Alex Philpott
    %[dec,RA] = r_to_angles(r)
    %Returns declination and right ascension in radians, given r
    
    %Assigning constants
    magn_r = (r(1)^2 + r(2)^2 + r(3)^2)^0.5;
    x = r(1);
    y = r(2);
    z = r(3);
    
    %Finding direction cosines
    l = x./magn_r;
    m = y./magn_r;
    n = z./magn_r;
    
    %Calculating dec
    dec = asin(n);
    
    %Calculating RA
    if m > 0
        RA = acos(l./cos(dec));
    else
        RA = 2.*pi - acos(l./cos(dec));
    end
    
end