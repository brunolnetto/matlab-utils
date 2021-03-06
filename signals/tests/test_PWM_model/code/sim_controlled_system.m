% Initial conditions
x0 = [0; 0];
xhat0 = [i_ref; 0];
step_ref = torque_ref;
u0 = - params.Kp*xhat0;

e0 = step_ref - Ctilde*xhat0;

load_system(model_name);

simMode = get_param(model_name, 'SimulationMode');
set_param(model_name, 'SimulationMode', 'normal', ...
                      'AlgebraicLoopSolver','LineSearch');

cs = getActiveConfigSet(model_name);
mdl_cs = cs.copy;
set_param(mdl_cs, 'SolverType','Fixed-step', 'FixedStep', '1e-5', ...
                  'SaveState','on','StateSaveName','xoutNew', ...
                  'SaveOutput','on','OutputSaveName','youtNew');

t0 = tic();
simOut = sim(model_name, mdl_cs);
toc(t0);

output = simOut.output;
states = simOut.states;
u_n = simOut.u_n;

tspan = simOut.states.time;

ang_vel = simOut.states.signals.values(:, 1);
current = simOut.states.signals.values(:, 2);

t_u = simOut.u_n.time;
u = simOut.u_n.signals.values;

torque = simOut.output.signals.values;
