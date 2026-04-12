%% 2.D Anisotropic Diffusion for Radar Imaging
% Carlos Ceballos - ECE PDE Project
clear; clc; close all;

%% 1. Setup Synthetic Radar Image
N = 128;
[X, Y] = meshgrid(1:N, 1:N);
% Create a "Target" (Gaussian Blob)
target = 1.0 * exp(-((X-64).^2 + (Y-64).^2) / (2*10^2));
% Add heavy noise
noise_lvl = 0.4;
u0 = target + noise_lvl * randn(N, N);
u = u0; % Initial state

%% 2. PDE Parameters
dt = 0.1;       % Time step
K = 0.15;       % Edge sensitivity (the "k" parameter)
lambda = 0.1;   % Fidelity weight
iterations = 500;

figure('Color', 'w', 'Position', [100, 100, 900, 400]);

%% 3. The PDE Evolution Loop
for t = 1:iterations
    % Compute Gradients (Central Differences)
    [ux, uy] = gradient(u);
    grad_mag = sqrt(ux.^2 + uy.^2);
    
    % Compute Edge-Stopping Function c(|\nabla u|)
    c = exp(-(grad_mag/K).^2);
    
    % Compute the Flux: J = c * \nabla u
    Jx = c .* ux;
    Jy = c .* uy;
    
    % Compute Divergence: div(J)
    [Jxx, ~] = gradient(Jx);
    [~, Jyy] = gradient(Jy);
    divergence_term = Jxx + Jyy;
    
    % Update Rule: u_next = u + dt * (div(c*grad(u)) - lambda*(u - u0))
    u = u + dt * (divergence_term - lambda * (u - u0));
    
    % --- Visualizing the PDE in Action ---
    if mod(t, 5) == 0 || t == 1
        subplot(1,2,1); imagesc(u0); colormap jet; axis image;
        title('Original Noisy Radar Data');
        
        subplot(1,2,2); imagesc(u); colormap jet; axis image;
        title(['PDE Diffusion Loop: Iteration ', num2str(t)]);
        drawnow; % Forces MATLAB to update the figure
    end
end

fprintf('PDE Evolution Complete.\n');