function [q_vals, p_vals, ...
          qp_vals, pp_vals, qpp_vals] = ...
                rolling_smoothstep(t_i, interval, dt, degree_interp, ...
                                   symbs, model_params, points, sys)
    
    persistent phi_prev;
    
    % Begin and end points
    head = points(1).coords(1:2);
    tail = points(2).coords(1:2);
    
    points(1).coords
    points(2).coords
    
    % States derivatives
    r_val = smoothstep(t_i, interval, head, tail, degree_interp);
    drdt_val = ndsmoothstep(t_i, interval, head, tail, degree_interp, 1);
    dr2dt2_val = ndsmoothstep(t_i, interval, head, tail, degree_interp, 2);
    dr3dt3_val = ndsmoothstep(t_i, interval, head, tail, degree_interp, 3);
    
    R = model_params(2);
    
    % x and y time derivatives
    dxdt = drdt_val(1);
    dydt = drdt_val(2);
    
    dx2dt2 = dr2dt2_val(1);
    dy2dt2 = dr2dt2_val(2);
    
    dx3dt3 = dr3dt3_val(1);
    dy3dt3 = dr3dt3_val(2);
    
    % Theta and v time derivatives
    if((dxdt == 0)&&(dydt == 0))
        x_1 = points(1).coords(1);
        x_2 = points(2).coords(1);
        
        y_1 = points(1).coords(2);
        y_2 = points(2).coords(2);
        
        delta_x = x_2 - x_1;
        delta_y = y_2 - y_1;
        
        theta = atan2(delta_y, delta_x);
        v = 0;
        
        omega_theta = 0;
        vp = dx2dt2*cos(theta) + dy2dt2*sin(theta) - ...
             dxdt*omega_theta*sin(theta) + dydt*omega_theta*cos(theta);
        omegap_theta = 0;
        omega_phi = v/R;
        omegap_phi = vp/R;
    
    else
        theta = atan2(dydt, dxdt);
    
        v = dxdt*cos(theta) + dydt*sin(theta);
    
        omega_theta = (-dx2dt2*sin(theta) + dy2dt2*cos(theta))/v;
        vp = dx2dt2*cos(theta) + dy2dt2*sin(theta) - ...
             dxdt*omega_theta*sin(theta) + dydt*omega_theta*cos(theta);
        omegap_theta = (-omega_theta*vp - ...
                         dx3dt3*sin(theta) + ...
                         dy3dt3*cos(theta) - ...
                         dx2dt2*omega_theta*cos(theta) - ...
                         dy2dt2*omega_theta*sin(theta))/v;

        omega_phi = v/R;
        omegap_phi = vp/R;

    end
    
    if(t_i == 0)
        phi = points(1).coords(4);
    else
        phi = phi_prev + dt*v/R;
    end

    phi_prev = phi;
    
    q_vals = double([r_val; theta; phi]);
    p_vals = double([omega_theta; omega_phi]);
    qp_vals = double([drdt_val; omega_theta; omega_phi]);
    pp_vals = double([omegap_theta; omegap_phi]);
    
    C = sys.kin.C;
    Cp = sys.kin.Cp;
    q = sys.kin.q;
    p = sys.kin.p{end};
    pp = sys.kin.pp{end};
    qp = sys.kin.qp;
    
    qpp = Cp*p + C*pp;
    
    symbs = [q; p; symbs.'];
    vals = [q_vals; p_vals; model_params'];
    
    qpp_vals = subs(qpp, symbs, vals);
end