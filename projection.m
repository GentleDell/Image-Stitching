function [projImage, left_edge, left_delta, upper_edge, upper_delta, max_col_projimg, max_row_projimg] = projection( image, homography_mat, func )
% 使用基于双线性插值的inverse mapping获得变换后图像
% 输出包括变换后图像边界和原图边界的差，用于在全景拼接时对齐
% func:函数功能选择，可以选择只求映射后边界 'border' 或者完成图像映射 'projection';
%

projImage = [];
col_img = size(image,2);
row_img = size(image,1);

[left_edge, left_delta, upper_edge, upper_delta, max_col_projimg, max_row_projimg] = proj_border(col_img, row_img, homography_mat);    % 映射后图像的边界
if strcmp(func, 'border')
    return;
elseif strcmp(func, 'projection')
    for col = 1:max_col_projimg + left_delta   % x
        for row = 1:max_row_projimg + upper_delta    % y
            % 基于双线性内插的inverse mapping
            new_cord = [col-left_delta; row-upper_delta; 1];   % 归一化齐次坐标
            old_cord = homography_mat\new_cord; % inverse mapping
            old_cord = old_cord/old_cord(3);
            intold_cord = fix(old_cord);

            if intold_cord(2) < 1 || intold_cord(1) < 1 || intold_cord(2) > row_img-1 || intold_cord(1) > col_img-1     % 反映射到界外则不管
                continue;
            end

            k = old_cord-intold_cord;  % 坐标小数部分
            val = image(intold_cord(2), intold_cord(1), :)*(1-k(1))*(1-k(2)) ...  
                + image(intold_cord(2)+1, intold_cord(1), :)*k(2)*(1-k(1)) ...  
                + image(intold_cord(2), intold_cord(1)+1, :)*(1-k(2))*k(1) ...  
                + image(intold_cord(2)+1, intold_cord(1)+1,:)*k(1)*k(2);

            projImage(row, col, :) = val;  

    %         % Forward mapping 会导致有多个原图的点重复映射到同一点，而某些点则没有被映射到；
    %         % 因而出现黑点，并且映射结果会有扭曲
    %         projImage(round(new_cord(2)), round(new_cord(1)), :) = image(row,col, :);
        end
    end
    projImage = uint8(projImage);
end
% figure
% hold on
% imshow(projImage);
end

function [left_edge, left_delta, upper_edge, upper_delta, max_col_projimg, max_row_projimg] = proj_border(col_img, row_img, homography_mat)

upper_left = homography_mat*[1; 1; 1];
upper_right = homography_mat*[col_img; 1; 1];
bottom_right = homography_mat*[col_img; row_img; 1];
bottom_left = homography_mat*[1; row_img; 1];

min_col_projimg = min(upper_left(1), bottom_left(1));
max_col_projimg = round(max(upper_right(1), bottom_right(1)));
min_row_projimg = min(upper_left(2), upper_right(2));
max_row_projimg = round(max(bottom_left(2), bottom_right(2)));

% 求出图像延伸到负轴的长度，用于图像对齐
left_edge = round(min_col_projimg);
if left_edge == 0
    left_edge = left_edge + 1;
end
if min_col_projimg < 1
    left_delta = round(abs(min_col_projimg)) + 1;
else
    left_delta = 0;
end

upper_edge = round(min_row_projimg);
if left_edge == 0
    left_edge = left_edge + 1;
end
if min_row_projimg < 1
    upper_delta =  round(abs(min_row_projimg)) + 1;
else
    upper_delta = 0;
end

end