
% References: 
% 1. https://wenku.baidu.com/view/989636ec02d276a201292e17.html
% 2. https://blog.csdn.net/zyttae/article/details/42507541

% TO BE MODIFIED:
% 先做全景，再做tracking

clc
clear
close all

imgPath = 'C:\Users\Gentle Deng\Desktop\好玩的编程\MATLAB\image_lib\';
imgDir  = dir([imgPath '*.png']); % 遍历所有jpg格式文件
match_alg = 'SURF'; % 匹配算法选择

homography_mat = eye(3);
homography_list = eye(3);

for i = 1:length(imgDir)          % 遍历结构体就可以一一处理图片了
    img2 = imread([imgPath imgDir(i).name]); %读取每张图片
    
    if i ~= 1        
        % Matching
        if strcmp(match_alg, 'SIFT')
            [feature_img1, feature_img2] = SIFT_match(img1,img2); % ## 可能输出为空
        elseif strcmp(match_alg, 'SURF')
            [feature_img1, feature_img2] = SURF_match(img1,img2); % ## 可能输出为空
        end   
        
        % Solving——现在从右往左的图像会出现x轴压缩？？
        homography_mat = RANSAC_affine(img1, img2, feature_img1, feature_img2);
        %[~, ~, ~] = projection(img2,homography_mat);    % 这里只是用来看下映射结果
        
        if isempty(homography_mat)
            continue
        end
        homography_list(:,:,i) = homography_mat;    % 当前页的图像向上一页图像的变换矩阵
        
    end
    
    img1 = img2; 
    
    image_list{i} = img1;
    
end

if size(homography_list, 3) == 1
    error('Unable to find any homography matrix, please use other images!');
end

% 初始化全景图
% ！！ 向中间一张做变换会更好看，畸变更少
[init_pano_list, cornors] = init_panoimage(homography_list,image_list);

% 传入的是初始化的全景图像，
[pano_image] = Image_Stitching(init_pano_list, cornors,3);

imshow(pano_image);