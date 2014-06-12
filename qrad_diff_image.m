function [] = QradDiffImage(option)
% This is a demo program to show the use of 3-frame-difference image
% to capture moving object
% Frames are resized from 768*576 to 320*240 in order to reduce
% calculation
% And all colors have been removed
% An optional argument '-o' generate a video of simulation result
%
% Author: bitmingw
% Date Created: 11 Jun 2014
% Last modified: 12 Jun 2014

	bw_thres = 0.1;

	videoread = vision.VideoFileReader('camera2L.avi'); % default video
	videoplay = vision.VideoPlayer; % Play the transformed video

	if nargin < 1
		option = '';	% No argument given
	end

	if strcmp(option, '-o') == 1
		videowrite = vision.VideoFileWriter('camera2sim.avi');
	end

	frame = step(videoread);	% The first frame is discarded

	% Info of frames
	LENGTH = size(frame, 2);
	HEIGHT = size(frame, 1);
	R_LENGTH = 320;
	R_HEIGHT = 240;

	% Allocate memory for frames and difference frames
	quad_frames = zeros(R_HEIGHT, R_LENGTH, 4);	% Gray images, range 0~1
	dual_diff_frames = zeros(R_HEIGHT, R_LENGTH, 3);	% As above
	quad_diff_frame = zeros(R_HEIGHT, R_LENGTH);	% As above

	% The initial process
	for i = 1:4
		frame = step(videoread);
		frame = rgb2gray(frame);
		frame = imresize(frame, [240 320]);
		quad_frames(:,:,i) = frame;
	end

	for i = 1:3
		dual_diff_frames(:,:,i) = ... 
			abs(quad_frames(:,:,i + 1) - quad_frames(:,:,i));
		dual_diff_frames(:,:,i) = ...
			set_upper_bound(dual_diff_frames(:,:,i), 1);	% Gray should be 0~1
		quad_diff_frame = quad_diff_frame + dual_diff_frames(:,:,i);
	end

	quad_diff_frame = set_upper_bound(quad_diff_frame, 1);	% Gray should be 0~1
	quad_diff_frame = im2bw(quad_diff_frame, bw_thres);	% Change to binary image

	% step(videoplay, quad_diff_frame);	% DEBUG

	% The main loop
	while ~isDone(videoread)
		% Display or write to file
		if strcmp(option, '-o') == 1
			step(videowrite, quad_diff_frame);
		else
			step(videoplay, quad_diff_frame);
		end

		% Calculate for the next process
		for i = 1:3
			quad_frames(:,:,i) = quad_frames(:,:,i+1);
		end
		frame = step(videoread);
		frame = rgb2gray(frame);
		frame = imresize(frame, [240 320]);
		quad_frames(:,:,4) = frame;

		for i = 1:3
			dual_diff_frames(:,:,i) = ... 
				abs(quad_frames(:,:,i + 1) - quad_frames(:,:,i));
			dual_diff_frames(:,:,i) = ...
				set_upper_bound(dual_diff_frames(:,:,i), 1);	% Gray should be 0~1
		end

		quad_diff_frame = dual_diff_frames(:,:,1) + dual_diff_frames(:,:,2);
		quad_diff_frame = set_upper_bound(quad_diff_frame, 1);	% Gray should be 0~1
		quad_diff_frame = im2bw(quad_diff_frame, bw_thres);	% Change to binary image, threshold 0.1

	end

	release(videoread);
	if strcmp(option, '-o') == 1
		release(videowrite);
	else
		release(videoplay);
	end

end