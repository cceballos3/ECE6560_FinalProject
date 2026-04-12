%% "Significant Variation" PDE: Variable Fidelity Radar Denoising
% Carlos Ceballos - ECE Final Project
clear; clc; close all;

%% 1. Setup 2D Radar Environment
N = 128;
[X, Y] = meshgrid(1:N, 1:N);
% Create a Target Blob
target = 1.0 * exp(-((X-64).^2 + (Y-64).^2) / (2*10^2));
u0 = target + 0.3 * randn(N, N); % Noisy Input

%% 2. The "Significant" Tweak: Generate a Fidelity Map (lambda)
% Instead of one lambda, we make lambda a matrix.
% We use a simple gradient detector on the noisy data to find "points of interest"
[idx, idy] = gradient(u0);
edges = sqrt(idx.^2 + idy.^2);
% Normalize edges and scale lambda: High lambda at edges, Low lambda in background
lambda_base = 0.2;
lambda_map = lambda_base + 1.5 * (edges / max(edges(:))); 

%% 3. PDE Parameters
dt = 0.1;
u = u0; 
iterations = 100;%

figure('Color', 'w', 'Position', [100, 100, 950, 400]);

%% 4. The Loop (This is the core "Doing something" part)
for t = 1:iterations
    % Standard Laplacian
    [ux, uy] = gradient(u);
    [uxx, ~] = gradient(ux);
    [~, uyy] = gradient(uy);
    laplacian = uxx + uyy;
    
    % Update Rule with Spatially Varying Lambda
    % This is the Euler-Lagrange you derived, but with our 'smart' lambda_map
    u = u + dt * (laplacian - lambda_map .* (u - u0));
    
    % Visualization
    if mod(t, 10) == 0 || t == 1
        subplot(1,2,1); imagesc(u0); colormap jet; axis image;
        title('Original Noisy Radar');
        
        subplot(1,2,2); imagesc(u); colormap jet; axis image;
        title(['Variable-Fidelity PDE: Iteration ', num2str(t)]);
        drawnow;
    end
end
