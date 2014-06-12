function [] = get_hist_frame(nth_frame, hist_steps)
% This is a peripheral program to analyize the histogram of arbitrary frame
% The source of the program is 3-frame-difference image
% where n is the n-th frame of original image (approx. n-th diff image)
% 
% Author: bitmingw
% Date Created: 11 Jun 2014
% Last modified: 11 Jun 2014

	videoread = vision.VideoFileReader('camera2L.avi'); % default video
	videoplay = vision.VideoPlayer; % Play the transformed video
    
    for num_frames = 1:1:nth_frame
        frame = step(videoread);
    end
    
	% Info of frames
	LENGTH = size(frame, 2);
	HEIGHT = size(frame, 1);
	R_LENGTH = 320;
	R_HEIGHT = 240;

	% Allocate memory for frames and difference frames
	tri_frames = zeros(R_HEIGHT, R_LENGTH, 3);	% Gray images, range 0~1
	dual_diff_frames = zeros(R_HEIGHT, R_LENGTH, 2);	% As above
	tri_diff_frame = zeros(R_HEIGHT, R_LENGTH);	% As above

	% The initial process
	for i = 1:3
		frame = step(videoread);
		frame = rgb2gray(frame);
		frame = imresize(frame, [240 320]);
		tri_frames(:,:,i) = frame;
	end

	for i = 1:2
		dual_diff_frames(:,:,i) = ... 
			abs(tri_frames(:,:,i + 1) - tri_frames(:,:,i));
		dual_diff_frames(:,:,i) = ...
			set_upper_bound(dual_diff_frames(:,:,i), 1);	% Gray should be 0~1
	end

	tri_diff_frame = dual_diff_frames(:,:,1) + dual_diff_frames(:,:,2);
	tri_diff_frame = set_upper_bound(tri_diff_frame, 1);	% Gray should be 0~1
	
    scaled_diff_frame = ceil(tri_diff_frame * (hist_steps-1) +1);   % Rescale
    hist = zeros(1, hist_steps);
    for i = 1:1:R_HEIGHT
        for ii = 1:1:R_LENGTH
            gray_value = scaled_diff_frame(i, ii);
            hist(gray_value) = hist(gray_value) + 1;
        end
    end
    x_axis = linspace(0, 1, hist_steps);
    plot(x_axis, hist);
    
end