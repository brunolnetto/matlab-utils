n_t  = length(tspan);

tspan = states.time;

states_hat = simOut.states_hat; 

time = states_hat.time;
ihat = states_hat.signals.values(:, 2);

ihat = interp1(time, ihat, tspan);

torque_vec = torque_ref*ones(n_t, 1);

w_vec = w_ss*ones(n_t, 1);
i_vec = i_ref*ones(n_t, 1);

y = {[torque, ang_vel, current], ...
     [torque_vec, ihat, i_vec]};

markers = {'-', '--'};

plot_config.titles = repeat_str('', 3);
plot_config.xlabels = [repeat_str('', 3), 't [s]'];
plot_config.ylabels = {'$\tau$ [N $\cdot$ m]', ...
                       '$\omega$ [$\frac{rad}{s}$]', ...
                       '$i$ [A]'};
plot_config.legends = {{'$\tau(t)$', '$\tau^{\star}(t)$'}, ...
                       {'$i(t)$', '$\hat{i}(t)$', '$i^{\star}(t)$'}};
plot_config.grid_size = [3, 1];
plot_config.pos_multiplots = [1, 3, 3];
plot_config.markers = {{'-', 'k--'}, {'-', '--', 'k--'}};

[hfig_x, axs] = my_plot(tspan, y, plot_config);

axs{1}{1}.FontSize = 25;
axs{1}{2}.FontSize = 25;
axs{1}{3}.FontSize = 25;

u_sat = simOut.u_sat;
u_s = u_sat.signals.values;

us = {u, u_s};

markers = {'--', '-'};

plot_config.titles = repeat_str('', 1);
plot_config.xlabels = {'t [s]'};
plot_config.ylabels = {'$\alpha$ [\%]'};
plot_config.grid_size = [1, 1];
plot_config.plot_type = 'stairs';

plot_config.legends = {'$\alpha(t)$', '$\alpha_{sat}(t)$'};
plot_config.pos_multiplots = 1;
plot_config.markers = markers;

[hfig_alpha, axs] = my_plot(t_u, us, plot_config);

axs{1}{1}.FontSize = 25;
axs{1}{1}.YLim = [0, 2];

% Save folder
path = [pwd '/../imgs/'];

if(strcmp(prefix, 'pwm'))
    u_pwm = simOut.u_pwm;

    t_p = u_pwm.time;
    u_p = u_pwm.signals.values;
    
    plot_config.titles = repeat_str('', 1);
    plot_config.xlabels = {'t [s]'};
    plot_config.ylabels = {'$u$ [V]'};
    plot_config.grid_size = [1, 1];

    [hfig_pwm, axs] = my_plot(t_p, u_p, plot_config);
    
    scaler = 1.2;
    
    axs{1}{1}.FontSize = 25;
    axs{1}{1}.YLim = [0, scaler*Vcc_val];

    fname = '_pwm_obsv';
    saveas(hfig_pwm, [path, prefix, fname], 'epsc');
end

fname = '_x_obsv';
saveas(hfig_x, [path, prefix, fname], 'epsc');

fname = '_alpha_obsv';
saveas(hfig_alpha, [path, prefix, fname], 'epsc');


