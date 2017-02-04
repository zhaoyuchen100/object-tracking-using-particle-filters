%% This demo is for using particle filter to track a selected object of interest using live USB webcam.
%% The object inforamtion is encoded with rgb color.
%% Parameters
F_update = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];

Npop_particles = 4000;

Xstd_rgb = 20;
Xstd_pos = 10;
Xstd_vec = 10;

Xrgb_trgt = [0; 255; 0]; % the target color for tracking

%% Starting Video Camera

vid = videoinput('winvideo', 1);
vid.SelectedSourceName = 'input1';
set(vid, 'TriggerRepeat', Inf);
vid.FrameGrabInterval = 1;

Npix_resolution = get(vid, 'VideoResolution');
Nfrm_movie = 1000;

%% Object Tracking by Particle Filter
im = getsnapshot(vid);
PSF = fspecial('gaussian',11,5);
im_blur = imfilter(im,PSF,'conv');
% im_blur = mat2gray(rgb2lab(im_blur));
imshow(im_blur); 
% BW1 = edge(im_blur,'Canny');
% imshow(BW1);
disp('select center point');
[x_c,y_c] = getpts;
% Xrgb_trgt = [im_blur(x_c,y_c,1);im_blur(x_c,y_c,2);im_blur(x_c,y_c,3)];
% Xrgb_trgt = double(Xrgb_trgt);
% Xrgb_trgt = [0;255;0];
disp('select boundary');
[x_b,y_b] = getpts;
r = sqrt((x_b-x_c)^2+(y_b-y_c)^2);
X = create_particles([y_c,x_c], Npop_particles,r);
show_particles(X, im); 
hold on;draw_circle(x_c,y_c,r)
start(vid)
while 1
     % Getting Image
     Y_k = getsnapshot(vid);

     % Forecasting
     X = update_particles(F_update, Xstd_pos, Xstd_vec, X);

    % Calculating Likelihood
    L = calc_log_likelihood(Xstd_rgb, Xrgb_trgt, X(1:2, :), Y_k);
    [~,ind] = max(L);
%     figure(2);plot(L);
    % Resampling
    X = resample_particles(X, L);
    
    % Showing Image
    show_particles(X, Y_k);
 %    show_state_estimated(X, Y_k);
%     Par = CircleFitByPratt(X(1:2,:)');
%     [Par(1),Par(2),Par(3)] = circfit(X(1,:),X(2,:));
    hold on;
%     draw_circle(Par(2),Par(1),Par(3))
%     plot(X(1,ind),X(2,ind),'x','MarkerSize',10);
    hold off;
    flushdata(vid);

end

%% Stopping Video Camera

stop(vid)
delete(vid)
