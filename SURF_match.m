%% SURF ��������ȡ��ƥ��
function [feature_loc1, feature_loc2] = SURF_match(I1, I2)    
    %resize the two images.  
    I1=rgb2gray(I1);  
    I2=rgb2gray(I2);   

    %Find the SURF features.Ѱ��������  
    points1 = detectSURFFeatures(I1,'MetricThreshold',2000);  
    points2 = detectSURFFeatures(I2,'MetricThreshold',2000);   

    %Extract the features.������������  
    [f1, vpts1] = extractFeatures(I1, points1);  
    [f2, vpts2] = extractFeatures(I2, points2);  

    %Retrieve the locations of matched points. The SURF feature vectors are already normalized.  
    %����ƥ��  
    % indexPairs = matchFeatures(f1, f2, 'Prenormalized', true, 'MatchThreshold', 5, 'MaxRatio', 0.5) ;  
    indexPairs = matchFeatures(f1, f2, 'Prenormalized', true);
    matched_pts1 = vpts1(indexPairs(:, 1));  
    matched_pts2 = vpts2(indexPairs(:, 2));  

    feature_loc1 = matched_pts1.Location; % (x,y)
    feature_loc2 = matched_pts2.Location;
    
    % show_matches(I1, I2, feature_loc1, feature_loc2);
    
% ���ں���ʹ��RANSAC�㷨�޳�outliers����˲���Ҫ�ڴ˲�����д���
%     [feature_loc1, feature_loc2] = my_linear_outlier_detection(matched_pts1,matched_pts2, size(I1), size(I2));
    
%     [feature_loc1, feature_loc2] = my_linear_outlier_detection2(matched_pts1,matched_pts2);
    
end

%% my outliers detection. by Zhantao Deng 2018/03/08
function [feature_loc1, feature_loc2] = my_linear_outlier_detection(matched_pts1,matched_pts2, size1, size2)
    % ���� outliers �븽�� inliers �� match line �Ƕ����ϴ����ɸѡ�����Ƕ��������Ӧ��ͨ��ͳ�Ƶõ�
    Ang_threshold = 15/180*pi;
    
    % �����������ڽ��������������ޣ���Ϊ�ǹ����㣬������outlier
    PNum_threshold = 4;
    
    % �ж��Ƿ������ٽ���ľ������ޡ������ڲ�ͬ��С��ͼ���������ò�ͬ
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
    
    % ��ͼƬ��״��Ϊ��������ʹ�þ������޳�Ϊһ������Ӧ��Բ
    times_im1 = [1, size1(2)/size1(1); 1, size1(2)/size1(1)]';
    times_im2 = [1, size2(2)/size2(1); 1, size2(2)/size2(1)]';
    
    feature_loc1 = matched_pts1.Location; % (x,y)
    feature_loc2 = matched_pts2.Location;
    
   % main part
    for ct = 1:size(feature_loc1,1)
        temp_mat = repmat(feature_loc1(ct,:),[size(feature_loc1,1),1]);
        distance = sqrt(sum((( temp_mat - feature_loc1)*times_im1 ).^2, 2));
        neighbors = find( distance<Dis_threshold1 );    % ����С������
        if length(neighbors) < PNum_threshold % ����������������##���ڼ����㶼ƥ����Ҵ��һ��������޷����,������������£������ȼ��ĵ�ᱻ��Ϊinlier����ʹ���涼��ɾ�ˣ���Ϊһ��ʼ��������support��
            feature_loc1(ct,:) = nan;
        else
            delta_dis = feature_loc1([ct,neighbors'],:) - feature_loc2([ct,neighbors'],:);    % �Ѳ��Եĵ�ct����ڿ�ͷ�����治������
            thita = atan2(delta_dis(:,2), delta_dis(:,1));  % ����Ƕȡ���֮���Խӽ�90������Ϊ���ص����õģ����ǲ���
            delta_thi = abs(thita(1)-mean(thita(2:end)));
            if delta_thi > std(thita(2:end)) || delta_thi > Ang_threshold    % ���ھ�����ķ�Χ�����ߴ������ޣ��ܿ�����outlier
                feature_loc1(ct,:) = nan;
            end
        end
    end
    feature_loc2(isnan(feature_loc1(:,1)),:) = [];
    feature_loc1(isnan(feature_loc1(:,1)),:) = [];
    
    for ct = 1:size(feature_loc2,1)
        temp_mat = repmat(feature_loc2(ct,:),[size(feature_loc2,1),1]);
        distance = sqrt(sum((( temp_mat - feature_loc2)*times_im2).^2, 2));
        neighbors = find( distance<Dis_threshold2 );    % ����С������
        if length(neighbors) < PNum_threshold % ����������������##���ڼ����㶼ƥ����Ҵ��һ��������޷������������������������ٵ�����������⣩
            feature_loc2(ct,:) = nan;
        end
    end
    feature_loc1(isnan(feature_loc2(:,1)),:) = [];
    feature_loc2(isnan(feature_loc2(:,1)),:) = [];
end

%% my outliers detection 2. by Zhantao Deng 2018/03/22 ���� �ƺ�����
% function [feature_loc1, feature_loc2] = my_linear_outlier_detection2(matched_pts1,matched_pts2)
% % ����outliers��inliers��match lineб��������һ�ص㣬���м��
% 
%     feature_loc1 = matched_pts1.Location; % (x,y)
%     feature_loc2 = matched_pts2.Location;
% 
%     delta_dis = (feature_loc1 - feature_loc2);
%     slope = atan2(delta_dis(:,2), delta_dis(:,1));
% %     outliers = find( slope-mean(slope)>= std(slope) );
%     a0 = ones(1, 4);   % ��ʼ������
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