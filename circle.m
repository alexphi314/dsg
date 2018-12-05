function p = circle(x0,y0,r,color,label)
% Plots circle with radius r located at x0, y0
% Call: circle(x0,y0,r,color,label)
hold on;
th = linspace(0,2*pi,100);
xp = x0 + r*cos(th);
yp = y0 + r*sin(th);
p = plot(xp,yp,'color',color,'DisplayName',label,'LineWidth',2);
end