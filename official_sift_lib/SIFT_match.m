% original version: num = match(image1, image2)
% Modified by Zhantao Deng @SJTU, 29/03/2018
%
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the matched features of given images.
%

function [feature_img1, feature_img2] = SIFT_match(image1, image2)

% Find SIFT keypoints for each image
[~, des1, loc1] = sift(image1);
[~, des2, loc2] = sift(image2);

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.6;   

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

feature_img1 = [];
feature_img2 = [];

img1_matchloc = find(match > 0);
img2_matchloc = match(match > 0);
feature_img1 = [loc1(img1_matchloc, 2),loc1(img1_matchloc, 1)];
feature_img2 = [loc2(img2_matchloc, 2),loc2(img2_matchloc, 1)] ;

% show_matches(image1, image2, feature_img1, feature_img2);

% for i = 1: size(des1,1)   % this part can be optimized as above
%   if (match(i) > 0)
%      feature_img1 = [feature_img1; [loc1(i,2),loc1(i,1)]]; % (row, column) -> (x,y)
%      feature_img2 = [feature_img2; [loc2(match(i),2),loc2(match(i),1)]];
%   end
% end

end




