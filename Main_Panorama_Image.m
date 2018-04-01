
% References: 
% 1. https://wenku.baidu.com/view/989636ec02d276a201292e17.html
% 2. https://blog.csdn.net/zyttae/article/details/42507541

% TO BE MODIFIED:
% ����ȫ��������tracking

clc
clear
close all

imgPath = 'C:\Users\Gentle Deng\Desktop\����ı��\MATLAB\image_lib\';
imgDir  = dir([imgPath '*.png']); % ��������jpg��ʽ�ļ�
match_alg = 'SURF'; % ƥ���㷨ѡ��

homography_mat = eye(3);
homography_list = eye(3);

for i = 1:length(imgDir)          % �����ṹ��Ϳ���һһ����ͼƬ��
    img2 = imread([imgPath imgDir(i).name]); %��ȡÿ��ͼƬ
    
    if i ~= 1        
        % Matching
        if strcmp(match_alg, 'SIFT')
            [feature_img1, feature_img2] = SIFT_match(img1,img2); % ## �������Ϊ��
        elseif strcmp(match_alg, 'SURF')
            [feature_img1, feature_img2] = SURF_match(img1,img2); % ## �������Ϊ��
        end   
        
        % Solving�������ڴ��������ͼ������x��ѹ������
        homography_mat = RANSAC_affine(img1, img2, feature_img1, feature_img2);
        %[~, ~, ~] = projection(img2,homography_mat);    % ����ֻ����������ӳ����
        
        if isempty(homography_mat)
            continue
        end
        homography_list(:,:,i) = homography_mat;    % ��ǰҳ��ͼ������һҳͼ��ı任����
        
    end
    
    img1 = img2; 
    
    image_list{i} = img1;
    
end

if size(homography_list, 3) == 1
    error('Unable to find any homography matrix, please use other images!');
end

% ��ʼ��ȫ��ͼ
% ���� ���м�һ�����任����ÿ����������
[init_pano_list, cornors] = init_panoimage(homography_list,image_list);

% ������ǳ�ʼ����ȫ��ͼ��
[pano_image] = Image_Stitching(init_pano_list, cornors,3);

imshow(pano_image);