function bounded_mat = setUpperBound(mat, upbound)
% This function set all elements in a matrix to a given value
% if they exceed the value previously
% upbound is a real number
%
% Author: bitmingw
% Date Created: 27 May 2014
% Last modified: 27 May 2014

	bounded_mat = [];	% Return none indicates an error
	LENGTH = size(mat, 2);
	HEIGHT = size(mat, 1);
	for i = 1:HEIGHT
		for ii = 1:LENGTH
			if mat(i, ii) > upbound
				mat(i, ii) = upbound;
			end
		end
	end
	bounded_mat = mat;

end