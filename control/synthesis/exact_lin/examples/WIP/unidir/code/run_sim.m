% [s]
tf = 2*pi/w;

model_name = 'tracking_model2';
simOut = simsys(model_name, sys, x0, tf);

q = simOut.coordinates.signals.values;
p = simOut.p_speeds.signals.values;
x = [q, p];

tspan = simOut.tout;
states = simOut.states.signals.values;
traj = simOut.traj.signals.values;
u = simOut.u.signals.values;
