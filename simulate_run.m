function [success, traj] = simulate_run(params)
% simulate_run - simulate a single trench-run trial
% Inputs: params struct (see trench_run_simulator.m)
% Outputs: success (logical), traj: 2xT array [x; y]

dt = params.dt;
max_t = params.max_t;
target_x = params.target_x;
port_r = params.port_radius;

x = 0;
y = 0;
t = 0;

v = params.xwing_speed;
weave_sigma = params.weave_sigma;
tie_fire_rate = params.tie_fire_rate;

fired = false;
success = false;

xs = x; ys = y;

while t < max_t && x < target_x
    % update forward motion
    x = x + v * dt;
    % lateral weave: simple random walk scaled by sqrt(dt)
    y = y + weave_sigma * sqrt(dt) * randn;

    % chance of being destroyed by TIE fire during dt
    if rand < tie_fire_rate * dt
        % destroyed, fail
        success = false;
        break;
    end

    % fire when within firing distance (only once)
    if ~fired && (target_x - x) <= params.firing_distance
        fired = true;
        % aim error: normal offset (meters)
        aim_err = params.torpedo_aim_sigma * randn;
        % if aim error within port radius, success
        if abs(aim_err) <= port_r
            success = true;
        else
            success = false;
        end
        % We don't simulate torpedo travel time; assume instantaneous check at fire
        % stop simulation after firing (for speed)
        xs(end+1) = x; ys(end+1) = y; %#ok<AGROW>
        break;
    end

    t = t + dt;
    xs(end+1) = x; ys(end+1) = y; %#ok<AGROW>
end

traj = [xs; ys];
end
