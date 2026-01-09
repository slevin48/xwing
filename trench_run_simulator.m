% trench_run_simulator.m
% Simple X-wing trench run Monte Carlo simulator
% Creates a small animation/plots and prints the success rate
clear; close all; clc;

% Ensure path contains this file's folder
scriptDir = fileparts(mfilename('fullpath'));
if ~isempty(scriptDir)
    addpath(scriptDir);
end

rng(1); % reproducible

% Simulation parameters
params.target_x = 100;        % meters: location of exhaust port
params.port_radius = 1.0;     % meters: radius of the exhaust port
params.dt = 0.01;             % simulation timestep (s)
params.max_t = 60;            % max sim time (s)
params.firing_distance = 20;  % fire when within this distance to target (m)
params.torpedo_aim_sigma = 0.75; % meters: aiming error standard deviation
params.xwing_speed = 150;     % m/s forward speed along trench
params.weave_sigma = 0.2;     % m lateral jitter (std dev per second)
params.tie_fire_rate = 0.02;  % per-second chance of X-wing being hit by TIE fire

Nsim = 1000;                  % number of Monte Carlo trials
fprintf('Running %d Monte Carlo trials...\n', Nsim);

success_count = 0;
sample_success_traj = [];
sample_fail_traj = [];

tic
for k=1:Nsim
    [success, traj] = simulate_run(params);
    if success
        success_count = success_count + 1;
        if isempty(sample_success_traj)
            sample_success_traj = traj;
        end
    else
        if isempty(sample_fail_traj)
            sample_fail_traj = traj;
        end
    end
end
elapsed = toc;
rate = success_count / Nsim;
fprintf('Simulation done in %.2f s. Success rate = %d / %d = %.3f\n', elapsed, success_count, Nsim, rate);

% Plot sample trajectories and a histogram of aim errors (by rerunning small sample)
figure('Name','Trench Run: sample trajectories','NumberTitle','off'); hold on; grid on; axis equal;
xlabel('x (m)'); ylabel('lateral y (m)');
title(sprintf('Sample trajectories (success rate = %.1f%%)', rate*100));
if ~isempty(sample_success_traj)
    plot(sample_success_traj(1,:), sample_success_traj(2,:), '-g', 'LineWidth', 1.5);
    legendItems{1} = 'example success';
end
if ~isempty(sample_fail_traj)
    plot(sample_fail_traj(1,:), sample_fail_traj(2,:), '-r', 'LineWidth', 1.5);
    legendItems{2} = 'example fail';
end
plot([params.target_x params.target_x], ylim(), '--k', 'LineWidth', 1);
text(params.target_x, mean(ylim()), ' target', 'HorizontalAlignment','left');
if exist('legendItems','var')
    legend(legendItems,'Location','best');
end

saveas(gcf, fullfile(scriptDir,'trench_run_sample_trajectories.png'));

% Quick distribution of hits by sampling aim errors (analytic view)
Ns = 2000;
aims = params.torpedo_aim_sigma * randn(Ns,1);
figure('Name','Aim error distribution','NumberTitle','off');
histogram(aims,50); hold on; ylims = ylim();
patch([-params.port_radius params.port_radius params.port_radius -params.port_radius], [0 0 ylims(2) ylims(2)], [0.8 0.9 1], 'FaceAlpha',0.3, 'EdgeColor','none');
xlabel('lateral aim error (m)'); ylabel('count');
title('Torpedo aim error distribution (shaded = success region)');
saveas(gcf, fullfile(scriptDir,'trench_run_aim_histogram.png'));

% Save a small text summary
fid = fopen(fullfile(scriptDir,'trench_run_summary.txt'),'w');
fprintf(fid,'Trench run Monte Carlo summary\n');
fprintf(fid,'Nsim = %d\n', Nsim);
fprintf(fid,'Successes = %d\n', success_count);
fprintf(fid,'Success rate = %.4f\n', rate);
fprintf(fid,'Parameters:\n');
fprintf(fid,' target_x=%.1f m, port_radius=%.2f m, firing_distance=%.1f m\n', params.target_x, params.port_radius, params.firing_distance);
fclose(fid);

fprintf('Saved sample images and summary into folder: %s\n', scriptDir);
