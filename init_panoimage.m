function [init_pano_list, cornors] = init_panoimage(homography_list,image_list)
% ��ʼ��ȫ��ͼ�Ĳ�ͬ�㣬ÿһ���Ӧ��һ��ԭʼͼ�����м��ͼ��ӳ���Ľ������ӳ��λ���⣬����λ����0��
% homography_list: ��Ӧ�����б�
% image_Ptr: ԭʼ�����ָ������
%

homography = eye(3);
cornors = [0 0 0 0 0 0]; % ����ÿ��ͼ�ı߽�ֵ���Ա������м�ͼ�Լ��õ�ȫ��ͼ��С

%% ȫ�����һ��ͼ��ӳ�䣬�õ��м�λ�õ�ͼ���ţ����������������Ч����
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
    
    % del��del�ϣ����ϣ� �ң���
    cornors(ct,:) = [left_delta, upper_delta, left_edge, upper_edge, size(proj_img,2), size(proj_img,1)];
    proj_img_list{ct} = proj_img;
end

%% ���м�ͼ��ӳ��

%% �õ���ʼ���ĸ���ȫ��ͼ
[left_limit, left_limit_img] = max(cornors(:,1));    % ��೬��������Ĵ�С���Լ��������ķ�ͼ
[upper_limit, upper_limit_img] = max(cornors(:,2));    % �Ϸ�����������Ĵ�С���Լ��������ķ�ͼ
[right_limit, right_limit_img] = max(cornors(:,5));    % �Ҳ೬��������Ĵ�С���Լ��������ķ�ͼ
[bottom_limit, bottom_limit_img] = max(cornors(:,6));  % �·�����������Ĵ�С���Լ��������ķ�ͼ

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
if num ~= limit(1,2) && limit(1,1) ~= 0 % ��������ͼ������ҪŲ��
    fill = zeros(size(image,1), limit(1,1), layers);
    image(:,end+1:end+limit(1,1), :) = fill;    % ��ĩβ�����ָ����
    image(:, limit(1,1)+1:end,:) =  image(:,1:end - limit(1,1),:);    % ��ͼ��ƽ��
    image(:, 1:limit(1,1), :) =  fill;  % ��ԭλ����0
end

if num ~= limit(2,2) &&  limit(2,1)~= 0 % ��������ͼ������ҪŲ��
    fill = uint8(zeros( limit(2,1), size(image,2), layers));
    image( end+1: end+limit(2,1), :, :) = fill;    % ��ĩβ�����ָ����
    image( limit(2,1)+1:end, :, :) =  image(1:end - limit(2,1), :, :);    % ��ͼ��ƽ��
    image( 1:limit(2,1), :, :) =  fill;  % ��ԭλ����0
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