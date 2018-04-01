%% SURF 特征点提取与匹配
function [feature_loc1, feature_loc2] = SURF_match(I1, I2)    
    %resize the two images.  
    I1=rgb2gray(I1);  
    I2=rgb2gray(I2);   

    %Find the SURF features.寻找特征点  
    points1 = detectSURFFeatures(I1,'MetricThreshold',2000);  
    points2 = detectSURFFeatures(I2,'MetricThreshold',2000);   

    %Extract the features.计算描述向量  
    [f1, vpts1] = extractFeatures(I1, points1);  
    [f2, vpts2] = extractFeatures(I2, points2);  

    %Retrieve the locations of matched points. The SURF feature vectors are already normalized.  
    %进行匹配  
    % indexPairs = matchFeatures(f1, f2, 'Prenormalized', true, 'MatchThreshold', 5, 'MaxRatio', 0.5) ;  
    indexPairs = matchFeatures(f1, f2, 'Prenormalized', true);
    matched_pts1 = vpts1(indexPairs(:, 1));  
    matched_pts2 = vpts2(indexPairs(:, 2));  

    feature_loc1 = matched_pts1.Location; % (x,y)
    feature_loc2 = matched_pts2.Location;
    
    % show_matches(I1, I2, feature_loc1, feature_loc2);
    
% 由于后续使用RANSAC算法剔除outliers，因此不需要在此步骤进行处理
%     [feature_loc1, feature_loc2] = my_linear_outlier_detection(matched_pts1,matched_pts2, size(I1), size(I2));
    
%     [feature_loc1, feature_loc2] = my_linear_outlier_detection2(matched_pts1,matched_pts2);
    
end

%% my outliers detection. by Zhantao Deng 2018/03/08
function [feature_loc1, feature_loc2] = my_linear_outlier_detection(matched_pts1,matched_pts2, size1, size2)
    % 利用 outliers 与附近 inliers 的 match line 角度相差较大进行筛选——角度门限最好应当通过统计得到
    Ang_threshold = 15/180*pi;
    
    % 如果被检测点的邻近点数量少于门限，认为是孤立点，可能是outlier
    PNum_threshold = 4;
    
    % 判定是否属于临近点的距离门限——对于不同大小的图像，门限设置不同
    if min(size1) > 1000
        Dis_threshold1 = 80;
    else
        Dis_threshold1 = min(size1)/10;
    end
    if min(size2) > 1000
        Dis_threshold2 = 80;
    else
        Dis_threshold2 = min(size2)/10;
    end
    
    % 将图片形状作为参数——使得距离门限成为一个自适应椭圆
    times_im1 = [1, size1(2)/size1(1); 1, size1(2)/size1(1)]';
    times_im2 = [1, size2(2)/size2(1); 1, size2(2)/size2(1)]';
    
    feature_loc1 = matched_pts1.Location; % (x,y)
    feature_loc2 = matched_pts2.Location;
    
   % main part
    for ct = 1:size(feature_loc1,1)
        temp_mat = repmat(feature_loc1(ct,:),[size(feature_loc1,1),1]);
        distance = sqrt(sum((( temp_mat - feature_loc1)*times_im1 ).^2, 2));
        neighbors = find( distance<Dis_threshold1 );    % 距离小于门限
        if length(neighbors) < PNum_threshold % 孤立特征点舍弃（##对于几个点都匹配错且错的一样的情况无法解决,而且这种情况下，往往先检测的点会被作为inlier，即使后面都被删了，因为一开始有其他点support）
            feature_loc1(ct,:) = nan;
        else
            delta_dis = feature_loc1([ct,neighbors'],:) - feature_loc2([ct,neighbors'],:);    % 把测试的点ct添加在开头，后面不用再找
            thita = atan2(delta_dis(:,2), delta_dis(:,1));  % 计算角度——之所以接近90度是因为是重叠放置的，而非并排
            delta_thi = abs(thita(1)-mean(thita(2:end)));
            if delta_thi > std(thita(2:end)) || delta_thi > Ang_threshold    % 大于均方差的范围，或者大于门限，很可能是outlier
                feature_loc1(ct,:) = nan;
            end
        end
    end
    feature_loc2(isnan(feature_loc1(:,1)),:) = [];
    feature_loc1(isnan(feature_loc1(:,1)),:) = [];
    
    for ct = 1:size(feature_loc2,1)
        temp_mat = repmat(feature_loc2(ct,:),[size(feature_loc2,1),1]);
        distance = sqrt(sum((( temp_mat - feature_loc2)*times_im2).^2, 2));
        neighbors = find( distance<Dis_threshold2 );    % 距离小于门限
        if length(neighbors) < PNum_threshold % 孤立特征点舍弃（##对于几个点都匹配错且错的一样的情况无法解决，另外整体点数本来就少的情况会有问题）
            feature_loc2(ct,:) = nan;
        end
    end
    feature_loc1(isnan(feature_loc2(:,1)),:) = [];
    feature_loc2(isnan(feature_loc2(:,1)),:) = [];
end

%% my outliers detection 2. by Zhantao Deng 2018/03/22 —— 似乎不行
% function [feature_loc1, feature_loc2] = my_linear_outlier_detection2(matched_pts1,matched_pts2)
% % 利用outliers与inliers的match line斜率相差大这一特点，进行检测
% 
%     feature_loc1 = matched_pts1.Location; % (x,y)
%     feature_loc2 = matched_pts2.Location;
% 
%     delta_dis = (feature_loc1 - feature_loc2);
%     slope = atan2(delta_dis(:,2), delta_dis(:,1));
% %     outliers = find( slope-mean(slope)>= std(slope) );
%     a0 = ones(1, 4);   % 初始化参数
%     [ para, resnorm ] = lsqcurvefit( @subfun, a0, feature_loc1(:,1), slope );
% 
%     feature_loc1(outliers,:) = [];
%     feature_loc2(outliers,:) = [];
%     
% end
% 
% function y = subfun( a, x )
%     y = a(1) + a(2)*x + a(3)*x^2 + a(4)*x^3;
% end