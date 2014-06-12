function [] = TriDiffImage(option)
% This is a demo program to show the use of 3-frame-difference image
% to capture moving object
% And a box is added to locate the moving objects in each frame
% Frames are resized from 768*576 to 320*240 in order to reduce
% calculation
% And all colors have been removed
% An optional argument '-o' generate a video of simulation result
%
% Author: bitmingw
% Date Created: 12 Jun 2014
% Last modified: 12 Jun 2014

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
	tri_diff_frame = wiener2(tri_diff_frame, [5 5]);	% Suppress the noise
	tri_diff_frame = im2bw(tri_diff_frame, 0.1);	% Change to binary image
	tri_diff_frame = disp_motion_track_box(tri_diff_frame);	% Show moving objects with boxes

	% step(videoplay, tri_diff_frame);	% DEBUG

	% The main loop
	while ~isDone(videoread)
		% Display or write to file
		if strcmp(option, '-o') == 1
			step(videowrite, tri_diff_frame);
		else
			step(videoplay, tri_diff_frame);
		end

		% Calculate for the next process
		for i = 1:2
			tri_frames(:,:,i) = tri_frames(:,:,i+1);
		end
		frame = step(videoread);
		frame = rgb2gray(frame);
		frame = imresize(frame, [240 320]);
		tri_frames(:,:,3) = frame;

		for i = 1:2
			dual_diff_frames(:,:,i) = ... 
				abs(tri_frames(:,:,i + 1) - tri_frames(:,:,i));
			dual_diff_frames(:,:,i) = ...
				set_upper_bound(dual_diff_frames(:,:,i), 1);	% Gray should be 0~1
		end

		tri_diff_frame = dual_diff_frames(:,:,1) + dual_diff_frames(:,:,2);
		tri_diff_frame = set_upper_bound(tri_diff_frame, 1);	% Gray should be 0~1
		tri_diff_frame = wiener2(tri_diff_frame, [5 5]);	% Suppress noise
		tri_diff_frame = im2bw(tri_diff_frame, 0.1);	% Change to binary image, threshold 0.1
		tri_diff_frame = disp_motion_track_box(tri_diff_frame);	% Show moving objects with boxes
	end

	release(videoread);
	if strcmp(option, '-o') == 1
		release(videowrite);
	else
		release(videoplay);
	end

end