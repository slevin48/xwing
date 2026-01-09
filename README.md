X-wing trench run simulator (MATLAB)

![vscode](image.png)

Files:
- trench_run_simulator.m : main script. Runs a Monte Carlo sample, saves images and summary.
- simulate_run.m : helper function, simulates one trial.

How to run:
1) Open MATLAB and change directory to this folder (c:/Users/ydebray/Downloads/MCP-test/).
2) Run:
   trench_run_simulator

Outputs created:
- trench_run_sample_trajectories.png
- trench_run_aim_histogram.png
- trench_run_summary.txt

Notes:
- This is a simple stochastic simulator (toy model) showing how aim error maps to success.
- It's intentionally simple and easy to extend: you can add explicit torpedo flight, TIE engagements, or pilot skill models.
