function [diff_frame] = disp_motion_track_box(diff_frame)
% This is a subroutine to track all the motion objects
% in a difference image which has been binarized
% 
% Author: bitmingw
% Date Created: 12 Jun 2014
% Last modified: 12 Jun 2014

	LENGTH = size(diff_frame, 2);
	HEIGHT = size(diff_frame, 1);

	SEARCH_RATIO = 0.01;
	ASSERT_BOUND_RATIO = 0.2;
	ASSERT_AREA_RATIO = 0.05;
	min_box_len = SEARCH_RATIO * LENGTH;
	min_box_hit = SEARCH_RATIO * HEIGHT;

	x1 = 0; y1 = 0;	% Upper left point in a area
	x2 = 0; y2 = 0;	% Bottom right point in a area
	targets = [];	% One row as a record
	num_targets = 0;	% The number of boxes

	% First round, global search to find several
	% possible areas
	x_bound = bw_thres_lines(diff_frame, 'LR', SEARCH_RATIO);
	y_bound = bw_thres_lines(diff_frame, 'UD', SEARCH_RATIO);

	% Possible area exists
	if size(x_bound, 2) >= 2 && size(y_bound, 2) >= 2
		% Second round, judge on each possible area
		% Note the step is 2
		for i = 1:2:size(x_bound, 2)-1
			for ii = 1:2:size(y_bound, 2)-1
				% Settle the boundary of possible area
				x1 = x_bound(i);
				y1 = y_bound(ii);
				x2 = x_bound(i+1);
				y2 = y_bound(ii+1);
				% Check the size of area
				if x2 - x1 < min_box_len || y2 - y1 < min_box_hit
					continue;	% Skip too small box
				end
				% Check the boundary of area use search routine
				img_fragment = diff_frame(y1:y2, x1:x2);
				small_x_bound = bw_thres_lines(img_fragment, 'LR', ASSERT_BOUND_RATIO);
				small_y_bound = bw_thres_lines(img_fragment, 'UD', ASSERT_BOUND_RATIO);

				%%%% AREA RATIO is not checked in this version

				% SUCCESSFULLY find, register to the targets
				if size(small_x_bound, 2) >= 2 && size(small_y_bound, 2) >= 2
					num_targets = num_targets + 1;
					targets(num_targets, 1) = x1;
					targets(num_targets, 2) = y1;
					targets(num_targets, 3) = x2;
					targets(num_targets, 4) = y2;
				end
			end
		end

		% Last step, draw boxes!
		for i = 1:num_targets
			diff_frame = bw_draw_box(diff_frame, targets(i,:));
		end
	end
end