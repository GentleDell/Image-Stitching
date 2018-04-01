function [init_pano_list, cornors] = init_panoimage(homography_list,image_list)
% 初始化全景图的不同层，每一层对应着一张原始图像向中间的图像映射后的结果，除映射位置外，其他位置置0；
% homography_list: 单应矩阵列表
% image_Ptr: 原始矩阵的指针数组
%

homography = eye(3);
cornors = [0 0 0 0 0 0]; % 保存每张图的边界值，以便于求中间图以及得到全景图大小

%% 全部向第一幅图像映射，得到中间位置的图像编号（可以先输出，看看效果）
for ct = 1:length(image_list)
    
    homography = homography * homography_list(:,:,ct);
    
    if ct ~= 1
        [proj_img, left_edge, left_delta, upper_edge, upper_delta]  = projection( image_list{ct}, homography ); 
    else
        proj_img = image_list{ct};
        upper_delta = 0;
        left_delta = 0;
        left_edge = 1;
        upper_edge = 1;        
    end
    
    % del左，del上，左，上， 右，下
    cornors(ct,:) = [left_delta, upper_delta, left_edge, upper_edge, size(proj_img,2), size(proj_img,1)];
    proj_img_list{ct} = proj_img;
end

%% 向中间图像映射

%% 得到初始化的各层全景图
[left_limit, left_limit_img] = max(cornors(:,1));    % 左侧超出坐标轴的大小，以及来自于哪幅图
[upper_limit, upper_limit_img] = max(cornors(:,2));    % 上方超出坐标轴的大小，以及来自于哪幅图
[right_limit, right_limit_img] = max(cornors(:,5));    % 右侧超出坐标轴的大小，以及来自于哪幅图
[bottom_limit, bottom_limit_img] = max(cornors(:,6));  % 下方超出坐标轴的大小，以及来自于哪幅图

LIMIT = [left_limit, left_limit_img; 
         upper_limit, upper_limit_img;
         right_limit, right_limit_img;
         bottom_limit, bottom_limit_img];

for ct = 1:length(proj_img_list)
    init_pano_list{ct} = image_fillzeros(proj_img_list{ct},LIMIT, ct);
    
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

function image = image_fillzeros(image, limit, num)
layers = size(image,3);
if num ~= limit(1,2) && limit(1,1) ~= 0 % 不是起因图，且需要挪动
    fill = zeros(size(image,1), limit(1,1), layers);
    image(:,end+1:end+limit(1,1), :) = fill;    % 在末尾处添加指定行
    image(:, limit(1,1)+1:end,:) =  image(:,1:end - limit(1,1),:);    % 将图像平移
    image(:, 1:limit(1,1), :) =  fill;  % 将原位置置0
end

if num ~= limit(2,2) &&  limit(2,1)~= 0 % 不是起因图，且需要挪动
    fill = uint8(zeros( limit(2,1), size(image,2), layers));
    image( end+1: end+limit(2,1), :, :) = fill;    % 在末尾处添加指定行
    image( limit(2,1)+1:end, :, :) =  image(1:end - limit(2,1), :, :);    % 将图像平移
    image( 1:limit(2,1), :, :) =  fill;  % 将原位置置0
end
    
if size(image,2) < limit(3,1)
    delta = limit(3,1) - size(image,2);
    fill = zeros(size(image,1), delta, layers);
    image(:, end+1:end + delta, :) =  fill;
end

if size(image,1) < limit(4,1)
    delta = limit(4,1) - size(image,1);
    fill = zeros(delta, size(image,2),  layers);
    image( end+1:end + delta, :, :) =  fill;
end

end