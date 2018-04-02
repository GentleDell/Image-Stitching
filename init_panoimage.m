function [init_pano_list, corners] = init_panoimage(homography_list,image_list)
% ��ʼ��ȫ��ͼ�Ĳ�ͬ�㣬ÿһ���Ӧ��һ��ԭʼͼ�����м��ͼ��ӳ���Ľ������ӳ��λ���⣬����λ����0��
% homography_list: ��Ӧ�����б�
% image_Ptr: ԭʼ�����ָ������
%

homography = eye(3);
corners = [0 0 0 0 0 0]; % ����ÿ��ͼ�ı߽�ֵ���Ա������м�ͼ�Լ��õ�ȫ��ͼ��С
func1 = 'border';
func2 = 'projection';

%% ȫ�����һ��ͼ��ӳ�䣬�õ��м�λ�õ�ͼ���ţ����������������Ч����
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
    % del��del�ϣ����ϣ� �ң���
    corners(ct,:) = [left_delta, upper_delta, left_edge, upper_edge, right_edge, bottom_edge];
    proj_img_list{ct} = proj_img;
end

%% ���м�ͼ��ӳ��
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

%% �õ���ʼ���ĸ���ȫ��ͼ

if min(corners(:,3)) < 1
    corners(:,5) = corners(:,5) - min(corners(:,3))+1;
    corners(:,3) = corners(:,3) - min(corners(:,3))+1;  % ���������Խ���ͼ������任��λ�ã�
        
end
if min(corners(:,4)) < 1
    corners(:,6) = corners(:,6) - min(corners(:,4))+1;
    corners(:,4) = corners(:,4) - min(corners(:,4))+1;  % �������ϲ�Խ���ͼ������任��λ�ã�
end

[left_limit, left_limit_img] = max(corners(:,1));    % ��೬��������Ĵ�С���Լ��������ķ�ͼ
[upper_limit, upper_limit_img] = max(corners(:,2));    % �Ϸ�����������Ĵ�С���Լ��������ķ�ͼ
[right_limit, right_limit_img] = max(corners(:,5));    % �Ҳ೬��������Ĵ�С���Լ��������ķ�ͼ
[bottom_limit, bottom_limit_img] = max(corners(:,6));  % �·�����������Ĵ�С���Լ��������ķ�ͼ

LIMIT = [left_limit, left_limit_img; 
         upper_limit, upper_limit_img;
         right_limit, right_limit_img;
         bottom_limit, bottom_limit_img];

for ct = 1:length(proj_img_list)
    init_pano_list{ct} = image_fillzeros(proj_img_list{ct},LIMIT, corners,ct);
    
    % ����������к󳬳�ԭ��LIMIT���������ʱ����
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
if num ~= limit(1,2) && limit(1,1) ~= 0 % ��������ͼ������ҪŲ��
    region = limit(1,1) - corners(num,1);
    fill = uint8(zeros(size(image,1), region, layers));
    image(:,end + 1 : end + region, :) = fill;    % ��ĩβ�����ָ����
    image(:, region+1:end,:) =  image(:,1:end - region,:);    % ��ͼ��ƽ��
    image(:, 1:region, :) =  fill;  % ��ԭλ����0
end

if num ~= limit(2,2) &&  limit(2,1)~= 0 % ��������ͼ������ҪŲ��
    region = limit(2,1) - corners(num,2);
    fill = uint8(zeros( region, size(image,2), layers));
    image( end+1: end + region, :, :) = fill;    % ��ĩβ�����ָ����
    image( region+1:end, :, :) =  image(1:end - region, :, :);    % ��ͼ��ƽ��
    image( 1:region, :, :) =  fill;  % ��ԭλ����0
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