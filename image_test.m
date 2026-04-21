clear; clc; close all;

set(groot,'defaultFigureWindowStyle','normal')

I = imread('radar_image.png');

% Adjust these if needed
Ic = imcrop(I, [70 70 400 400]);   % [x y width height]

if size(Ic,3) == 3
    Igray = rgb2gray(Ic);
else
    Igray = Ic;
end

u0 = im2double(Igray);

lambda = 0.15;
dt = 0.1;
num_iters = 150;

u = u0;

for n = 1:num_iters
    u_old = u;

    up    = [u_old(1,:); u_old(1:end-1,:)];
    down  = [u_old(2:end,:); u_old(end,:)];
    left  = [u_old(:,1), u_old(:,1:end-1)];
    right = [u_old(:,2:end), u_old(:,end)];

    Lap_u = up + down + left + right - 4*u_old;

    u = u_old + dt*(2*(1-lambda)*Lap_u - lambda*(u_old - u0));
end

figure;
subplot(1,3,1);
imshow(Ic);
title('Color image');

subplot(1,3,2);
imshow(u0, []);
title('Grayscale input');

subplot(1,3,3);
imshow(u, []);
title('PDE output');

drawnow;