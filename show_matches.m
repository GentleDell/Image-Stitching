%% show matched features over images
function show_matches(I1,I2,feature_loc1,feature_loc2)
% I1: Image 1£»
% I2: Image 2;
% feature_loc1/2: feature points, N rows * 2 columns

height_I1 = size(I1,1);
height_I2 = size(I2,1);

if height_I2 > height_I1
    delta_I12 = 0;  % used to rectify the image2's features' location in synthesized image
    delta_I21 = (height_I2 - height_I1)/2; % used to rectify the image1's features' location in synthesized image
    I1_temp_up = zeros(floor(delta_I21), size(I1,2), size(I1,3));
    I1_temp_down = zeros(ceil(delta_I21), size(I1,2), size(I1,3));
    new_img = [I1_temp_up; I1; I1_temp_down];
    new_img = [new_img, I2];
elseif height_I2 < height_I1
    delta_I12 = (height_I1 - height_I2)/2;
    delta_I21 = 0;
    I2_temp_up = zeros(floor(delta_I12), size(I2,2), size(I2,3));
    I2_temp_down = zeros(ceil(delta_I12), size(I2,2), size(I2,3));
    new_img = [I2_temp_up; I2; I2_temp_down];
    new_img = [I1, new_img];
else
    new_img = [I1,I2];
    delta_I21 = 0;
    delta_I12 = 0;
end

base_col = size(I1,2);
figure
imshow(new_img);
hold on;
for ct = 1:size(feature_loc1,1)
    plot([feature_loc1(ct,1), base_col + feature_loc2(ct,1)],[ceil(delta_I21) + feature_loc1(ct,2), ceil(delta_I12) + feature_loc2(ct,2)],'g*');
    plot([feature_loc1(ct,1), base_col + feature_loc2(ct,1)],[ceil(delta_I21) + feature_loc1(ct,2), ceil(delta_I12) + feature_loc2(ct,2)], 'g' );
%     text(feature_loc1(ct,1),ceil(delta_I21) + feature_loc1(ct,2),num2str(ct));
end
    
end