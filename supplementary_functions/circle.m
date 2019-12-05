% function to plot a circle defined by its center coordinate and radius

function h = circle(x,y,r)

hold on
th    = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h     = plot(xunit, yunit,'y');
h(1).LineWidth = 2;
hold off

return
