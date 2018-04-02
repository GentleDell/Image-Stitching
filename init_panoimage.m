function [init_pano_list, corners] = init_panoimage(homography_list,image_list)
% 初始化全景图的不同层，每一层对应着一张原始图像向中间的图像映射后的结果，除映射位置外，其他位置置0；
% homography_list: 单应矩阵列表
% image_Ptr: 原始矩阵的指针数组
%

homography = eye(3);
corners = [0 0 0 0 0 0]; % 保存每张图的边界值，以便于求中间图以及得到全景图大小
func1 = 'border';
func2 = 'projection';

%% 全部向第一幅图像映射，得到中间位置的图像编号（可以先输出，看看效果）
for ct = 1:length(image_list)
    
    homography = homography * homography_list(:,:,ct);
    
%     if ct ~= 1
        [proj_img, left_edge, left_delta, upper_edge, upper_delta, right_edge, bottom_edge]  = projection( image_list{ct}, homography, func1 ); 
%     else
%         proj_img = image_list{ct};
%         upper_delta = 0;
%         left_delta = 0;
%         left_edge = 1;
%         upper_edge = 1;        
%         right_edge = size(proj_img,2);
%         bottom_edge = size(proj_img,1);
%     end
%     
    % del左，del上，左，上， 右，下
    corners(ct,:) = [left_delta, upper_delta, left_edge, upper_edge, right_edge, bottom_edge];
    proj_img_list{ct} = proj_img;
end

%% 向中间图像映射
%
new_homography_list = [];
[~,mid_img_num] = min( abs(corners(:,5) - mean(corners(:,5))) );

for ct = 1:length(image_list)
    temp_homo_mat = eye(3);
    if ct < mid_img_num
        for ct_homo = ct+1 : mid_img_num
            temp_homo_mat = homography_list(:,:,ct_homo) \ temp_homo_mat;
        end
    elseif ct > mid_img_num
        for ct_homo = mid_img_num+1 : ct
            temp_homo_mat = temp_homo_mat * homography_list(:,:,ct_homo);
        end
    end
    new_homography_list{ct} = temp_homo_mat;
    
    [proj_img, left_edge, left_delta, upper_edge, upper_delta, right_edge, bottom_edge]  = projection( image_list{ct}, temp_homo_mat, func2 ); 
    
    corners(ct,:) = [left_delta, upper_delta, left_edge, upper_edge, right_edge, bottom_edge];
    proj_img_list{ct} = proj_img;
end

%% 得到初始化的各层全景图

if min(corners(:,3)) < 1
    corners(:,5) = corners(:,5) - min(corners(:,3))+1;
    corners(:,3) = corners(:,3) - min(corners(:,3))+1;  % 对于有左侧越界的图像，求出变换后位置；
        
end
if min(corners(:,4)) < 1
    corners(:,6) = corners(:,6) - min(corners(:,4))+1;
    corners(:,4) = corners(:,4) - min(corners(:,4))+1;  % 对于有上侧越界的图像，求出变换后位置；
end

[left_limit, left_limit_img] = max(corners(:,1));    % 左侧超出坐标轴的大小，以及来自于哪幅图
[upper_limit, upper_limit_img] = max(corners(:,2));    % 上方超出坐标轴的大小，以及来自于哪幅图
[right_limit, right_limit_img] = max(corners(:,5));    % 右侧超出坐标轴的大小，以及来自于哪幅图
[bottom_limit, bottom_limit_img] = max(corners(:,6));  % 下方超出坐标轴的大小，以及来自于哪幅图

LIMIT = [left_limit, left_limit_img; 
         upper_limit, upper_limit_img;
         right_limit, right_limit_img;
         bottom_limit, bottom_limit_img];

for ct = 1:length(proj_img_list)
    init_pano_list{ct} = image_fillzeros(proj_img_list{ct},LIMIT, corners,ct);
    
    % 对于添加行列后超出原有LIMIT的情况，及时更新
    if size(init_pano_list{ct}, 1) > bottom_limit
        bottom_limit = size(init_pano_list{ct}, 1);
    end
    if size(init_pano_list{ct}, 2) > right_limit
        right_limit = size(init_pano_list{ct}, 2);
    end
    
    LIMIT = [left_limit, left_limit_img; 
         upper_limit, upper_limit_img;
         right_limit, right_limit_img;
         bottom_limit, bottom_limit_img];
end 

end

function image = image_fillzeros(image, limit, corners, num)
layers = size(image,3);
if num ~= limit(1,2) && limit(1,1) ~= 0 % 不是起因图，且需要挪动
    region = limit(1,1) - corners(num,1);
    fill = uint8(zeros(size(image,1), region, layers));
    image(:,end + 1 : end + region, :) = fill;    % 在末尾处添加指定行
    image(:, region+1:end,:) =  image(:,1:end - region,:);    % 将图像平移
    image(:, 1:region, :) =  fill;  % 将原位置置0
end

if num ~= limit(2,2) &&  limit(2,1)~= 0 % 不是起因图，且需要挪动
    region = limit(2,1) - corners(num,2);
    fill = uint8(zeros( region, size(image,2), layers));
    image( end+1: end + region, :, :) = fill;    % 在末尾处添加指定行
    image( region+1:end, :, :) =  image(1:end - region, :, :);    % 将图像平移
    image( 1:region, :, :) =  fill;  % 将原位置置0
end

if size(image,2) < limit(3,1)
    delta = limit(3,1) - size(image,2);
    fill = uint8(zeros(size(image,1), delta, layers));
    image(:, end+1:end + delta, :) =  fill;
end

if size(image,1) < limit(4,1)
    delta = limit(4,1) - size(image,1);
    fill = uint8(zeros(delta, size(image,2),  layers));
    image( end+1:end + delta, :, :) =  fill;
end

end