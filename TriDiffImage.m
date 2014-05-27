% This is a demo program to show the use of 3-frame-difference image
% to capture moving object
% The image are resize from 768*576 to 320*240 in order to reduce
% calculation
% The reduce is operated to gray image
%
% Author: bitmingw
% Date Created: 27 May 2014
% Last modified: 27 May 2014

videoread = vision.VideoFileReader('camera2.avi'); % default video
videoplay = vision.VideoPlayer; % Play the transformed video

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
		setUpperBound(dual_diff_frames(:,:,i), 1);	% Gray should be 0~1
end

tri_diff_frame = dual_diff_frames(:,:,1) + dual_diff_frames(:,:,2);
tri_diff_frame = setUpperBound(tri_diff_frame, 1);	% Gray should be 0~1

% step(videoplay, tri_diff_frame);	% DEBUG

% The main loop
while ~isDone(videoread)
	% Display the previous results
	step(videoplay, tri_diff_frame);

	% Calculate for the next process
	tri_frames(:,:,1) = tri_frames(:,:,2);
	tri_frames(:,:,2) = tri_frames(:,:,3);
	frame = step(videoread);
	frame = rgb2gray(frame);
	frame = imresize(frame, [240 320]);
	tri_frames(:,:,3) = frame;

	for i = 1:2
		dual_diff_frames(:,:,i) = ... 
			abs(tri_frames(:,:,i + 1) - tri_frames(:,:,i));
		dual_diff_frames(:,:,i) = ...
			setUpperBound(dual_diff_frames(:,:,i), 1);	% Gray should be 0~1
	end

	tri_diff_frame = dual_diff_frames(:,:,1) + dual_diff_frames(:,:,2);
	tri_diff_frame = setUpperBound(tri_diff_frame, 1);	% Gray should be 0~1

	pause(0.1);

end

release(videoplay);
release(videoread);