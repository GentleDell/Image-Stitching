function [homography_mat] = RANSAC_affine(image1, image2, feature_img1, feature_img2)
%% RANSAC ��Ӧ�Ծ������ �� outliers�޳� ���� �Ƚ��ϸ�inlier�����Ŀ�����
% image1:ԭͼ������չʾ
% image2: ��׼ͼ������չʾ
% homography_mat: ��Ӧ����
% feature_img1/2: img1/2 ������������, N��*2��

allcorrect_rate = 0.995; % Ҫ�����ٳ���һ�Ρ���ѡ��ȫ��inliers���¼��ĸ���
inlier_threshold = 5;    % ӳ�������inlier_threshold���ص�λ����Ϊ���ڵ�
admitted_threshold = 6;  % һ��homo֡���ٵõ�admitted_threshold����֧�ֲ���Ч��������һ��ʼ�ĸ����Ǵ��ȴ������
ransac_maxiterator = 2000;    % RANSAC�������ransac_iterator�Σ����ò������н��������

feature_num = size(feature_img1,1);
feature_img1 = [feature_img1,ones(feature_num,1)]'; % ��дΪ�������, 3��N��
feature_img2 = [feature_img2,ones(feature_num,1)]'; % ��дΪ������꣬3��N��

% ��ʼ���
loop_times = ransac_maxiterator;
max_inliner_num = 0;
all_inliers_index = [];
for row = 1:loop_times
    
    rand_index = randperm(feature_num);% ������������
    draw_rand_index = rand_index(1:4); % ȡ��ǰ���������,����ֻ��Ҫ4�㼴��;
    homography_mat = findHomography(feature_img1, feature_img2, draw_rand_index);
    
    % ���Ϊ��˵���ĵ㹲�� ����δ����
    if isempty(homography_mat)  
        continue;
    end
    % residual errors
    inliers_index = find(sqrt(sum((feature_img1 - homography_mat*feature_img2).^2)) <= inlier_threshold);
    inliers_num = length(inliers_index);
    if inliers_num > max(max_inliner_num,admitted_threshold)  % Ҫ����admitted_threshold����֧�֣������ĸ��㣬����admitted_threshold-4���㣩
        max_inliner_num = inliers_num;
        loop_times = min( ransac_maxiterator, ceil( log(1-allcorrect_rate)/log(1-(inliers_num/feature_num)^4)) ); % ����ѭ������,С���Ͻ�
        all_inliers_index = [all_inliers_index, setdiff(inliers_index, all_inliers_index)]; % ����inliers�����൱���޳�outliers
    end
end
% ��û���ҵ���Ч�ĵ�Ӧ����ֱ�ӷ���
if isempty(all_inliers_index)   
    homography_mat = [];
    return;
end

% �ҵ�����Ч�ĵ�Ӧ�������ô�����ڵ㼯���ٹ���һ�ε�Ӧ����
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