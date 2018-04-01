function [homography_mat] = RANSAC_affine(image1, image2, feature_img1, feature_img2)
%% RANSAC 单应性矩阵求解 与 outliers剔除 —— 比较严格，inlier点的数目会较少
% image1:原图像，用于展示
% image2: 配准图像，用于展示
% homography_mat: 单应矩阵
% feature_img1/2: img1/2 中特征点坐标, N行*2列

allcorrect_rate = 0.995; % 要求至少出现一次‘所选点全是inliers’事件的概率
inlier_threshold = 5;    % 映射误差在inlier_threshold像素单位内认为是内点
admitted_threshold = 6;  % 一个homo帧至少得到admitted_threshold个点支持才生效——避免一开始四个都是错的却被导入
ransac_maxiterator = 2000;    % RANSAC最多运行ransac_iterator次，还得不到可行解则输出空

feature_num = size(feature_img1,1);
feature_img1 = [feature_img1,ones(feature_num,1)]'; % 改写为齐次坐标, 3行N列
feature_img2 = [feature_img2,ones(feature_num,1)]'; % 改写为齐次坐标，3行N列

% 开始求解
loop_times = ransac_maxiterator;
max_inliner_num = 0;
all_inliers_index = [];
for row = 1:loop_times
    
    rand_index = randperm(feature_num);% 将序号随机排列
    draw_rand_index = rand_index(1:4); % 取出前个若干序号,最少只需要4点即可;
    homography_mat = findHomography(feature_img1, feature_img2, draw_rand_index);
    
    % 输出为空说明四点共线 或者未收敛
    if isempty(homography_mat)  
        continue;
    end
    % residual errors
    inliers_index = find(sqrt(sum((feature_img1 - homography_mat*feature_img2).^2)) <= inlier_threshold);
    inliers_num = length(inliers_index);
    if inliers_num > max(max_inliner_num,admitted_threshold)  % 要至少admitted_threshold个点支持（求解的四个点，额外admitted_threshold-4个点）
        max_inliner_num = inliers_num;
        loop_times = min( ransac_maxiterator, ceil( log(1-allcorrect_rate)/log(1-(inliers_num/feature_num)^4)) ); % 更新循环次数,小于上界
        all_inliers_index = [all_inliers_index, setdiff(inliers_index, all_inliers_index)]; % 保存inliers——相当于剔除outliers
    end
end
% 若没有找到有效的单应矩阵，直接返回
if isempty(all_inliers_index)   
    homography_mat = [];
    return;
end

% 找到了有效的单应矩阵，利用储存的内点集，再估计一次单应矩阵
homography_mat = findHomography(feature_img1, feature_img2, all_inliers_index);
inliers_img1 = feature_img1(:,all_inliers_index);
inliers_img2 = feature_img2(:,all_inliers_index);

% show_matches(image1,image2,inliers_img1',inliers_img2');
% show_homo(inliers_img1, inliers_img2, homography_mat);

end

function show_homo(homo_fea1, homo_fea2,homography_mat)
xy_ = homography_mat*homo_fea2;    
figure
hold on
plot(homo_fea1(1,:),homo_fea1(2,:),'*')
plot(homo_fea2(1,:),homo_fea2(2,:),'*')
plot(xy_(1,:),xy_(2,:),'.') 
end