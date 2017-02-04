%% This demo is for using particle filter to track a selected object of interest using a saved video.
%% The object inforamtion is encoded with rgb color.
%% Parameters
F_update = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];

Npop_particles = 4000;

Xstd_rgb = 50;
Xstd_pos = 10;
Xstd_vec = 10;
%% Loading Movie

vr = VideoReader('ball_balance_2.mp4');

Npix_resolution = [vr.Width vr.Height];
Nfrm_movie = floor(vr.Duration * vr.FrameRate);

%% Object Tracking by Particle Filter
im = readFrame(vr);
PSF = fspecial('gaussian',11,5);
im_blur = imfilter(im,PSF,'conv');
% im_blur = mat2gray(rgb2lab(im_blur));
imshow(im_blur); 
% BW1 = edge(im_blur,'Canny');
% imshow(BW1);
disp('select center point');
[x_c,y_c] = getpts;
Xrgb_trgt = [im_blur(x_c,y_c,1);im_blur(x_c,y_c,2);im_blur(x_c,y_c,3)];
% Xrgb_trgt = double(Xrgb_trgt);
Xrgb_trgt = [0;255;0];
disp('select boundary');
[x_b,y_b] = getpts;
r = sqrt((x_b-x_c)^2+(y_b-y_c)^2);

X = create_particles([y_c,x_c], Npop_particles,r);
show_particles(X, im); 

for k = 1:Nfrm_movie
    PSF = fspecial('gaussian',11,5);
    % Getting Image
    Y_k = readFrame(vr);
    Y_k = imfilter(Y_k,PSF,'conv');
    Y_k_blur = imfilter(Y_k,PSF,'conv');
%     Y_k_blur = mat2gray(rgb2lab(Y_k_blur));
    % Forecasting
    X = update_particles(F_update, Xstd_pos, Xstd_vec, X);
    
    % Calculating Log Likelihood
    L = calc_log_likelihood(Xstd_rgb, Xrgb_trgt, X(1:2, :), Y_k_blur);
    
    % Resampling
    X = resample_particles(X, L);

    % Showing Image
    show_particles(X, Y_k); 
%    show_state_estimated(X, Y_k);

end

