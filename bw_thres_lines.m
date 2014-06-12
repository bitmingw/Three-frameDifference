function [select_coord] = bw_thres_lines(bw_image, direction, ratio)
% This subroutine returns a horizontal vector of coordinates
% where these lines contain approx. ratio of white points
% directory indicates how to scan the image
% 'LR' scans left to right and returns x coordinates
% 'UD' scans up to down and returns y coordinates
%
% Author: bitmingw
% Date Created: 12 Jun 2014
% Last modified: 12 Jun 2014
	
	HEIGHT = size(bw_image, 1);
	LENGTH = size(bw_image, 2);
	COMBINE_RATIO = 0.05;	% Two blocks combines when they are close
	combine_len = LENGTH * COMBINE_RATIO;
	combine_hit = HEIGHT * COMBINE_RATIO;


	num_found = 0;
	select_coord = [];

	if strcmp(direction, 'LR')
		min_white_points = HEIGHT * ratio;
		x_distri = zeros(1, LENGTH);	% Record white points each column
		% Scan the whole image
		for i = 1:HEIGHT
			for ii = 1:LENGTH
				if bw_image(i, ii)
					x_distri(ii) = x_distri(ii) + 1;
				end
			end
		end

		% Special case: the 1st column
		if x_distri(1) >= min_white_points
			num_found = num_found + 1;
			select_coord(num_found) = 1;
		end

		% General case
		for ii = 1:LENGTH-1
			% Left edge
			if x_distri(ii) < min_white_points && ... 
					x_distri(ii+1) >= min_white_points
				num_found = num_found + 1;	% Find a new boundary
				select_coord(num_found) = ii;
			% Right edge
			elseif x_distri(ii) >= min_white_points && ...
					x_distri(ii+1) < min_white_points
				num_found = num_found + 1;
				select_coord(num_found) = ii;
			end
		end

		% Special case: the last column
		if x_distri(LENGTH) >= min_white_points
			num_found = num_found + 1;
			select_coord(num_found) = LENGTH;
		end
	end


	if strcmp(direction, 'UD')
		min_white_points = LENGTH * ratio;
		y_distri = zeros(1, HEIGHT);	% Record white points each row
		% Scan the whole image
		for i = 1:HEIGHT
			for ii = 1:LENGTH
				if bw_image(i, ii)
					y_distri(i) = y_distri(i) + 1;
				end
			end
		end

		% Special case: the 1st row
		if y_distri(1) >= min_white_points
			num_found = num_found + 1;
			select_coord(num_found) = 1;
		end

		% General case
		for i = 1:HEIGHT-1
			% Left edge
			if y_distri(i) < min_white_points && ... 
					y_distri(i+1) >= min_white_points
				num_found = num_found + 1;	% Find a new boundary
				select_coord(num_found) = i;
			% Right edge
			elseif y_distri(i) >= min_white_points && ...
					y_distri(i+1) < min_white_points
				num_found = num_found + 1;
				select_coord(num_found) = i;
			end
		end

		% Special case: the last column
		if y_distri(HEIGHT) >= min_white_points
			num_found = num_found + 1;
			select_coord(num_found) = HEIGHT;
		end
	end

	% Post process
	% Deal with errors
	if mod(size(select_coord, 2), 2)	% Error, not in pair
		select_coord = [];	% Clear the results
	end

	% Combine close blocks if necessary
	if size(select_coord, 2) >= 4
		if strcmp(direction, 'LR')
			i = 2;
			while i <= size(select_coord, 2)-2
				% If find, update size
				if select_coord(i+1) - select_coord(i) < ...
						combine_len
					% Move 2 elements forward by adding 0
					select_coord(i:end) = [select_coord(i+2:end) 0 0];
					% Delete last 2 elements
					select_coord = select_coord(1:size(select_coord, 2)-2);
				% If not find, update i
				else
					i = i + 2;
				end
			end
		end

		if strcmp(direction, 'UD')
			i = 2;
			while i <= size(select_coord, 2)-2
				% If find, update size
				if select_coord(i+1) - select_coord(i) < ...
						combine_hit
					% Move 2 elements forward by adding 0
					select_coord(i:end) = [select_coord(i+2:end) 0 0];
					% Delete last 2 elements
					select_coord = select_coord(1:size(select_coord, 2)-2);
				% If not find, update i
				else
					i = i + 2;
				end
			end
		end
	end

end