function [bw_image] = bw_draw_box(bw_image, coordinates)
% This subroutine draws a white box in a binary image
% coordinates is a 1*4 vector as [x1 y1 x2 y2]
%
% Author: bitmingw
% Date Created: 12 Jun 2014
% Last Modified: 12 Jun 2014
	x1 = coordinates(1);
	y1 = coordinates(2);
	x2 = coordinates(3);
	y2 = coordinates(4);
	LENGTH = size(bw_image, 2);
	HEIGHT = size(bw_image, 1);

	% Check all the inputs
	if 0 < x1 && x1 < x2 && x2 <= LENGTH && ...
			0 < y1 && y1 < y2 && y2 <= HEIGHT
		bw_image(y1:y2, x1) = 1;
		bw_image(y1:y2, x2) = 1;
		bw_image(y1, x1:x2) = 1;
		bw_image(y2, x1:x2) = 1;
	end
end