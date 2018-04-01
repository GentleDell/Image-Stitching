function [pano_image] = Image_Stitching(image_list, corners, iter)
%% Image stitching with multiple band blending
% image_list:ƴ��ͼ���б�
% corners: �ߴ���Ϣ��������������; ���� ͼ��Ļ������ط��ĺ�ɫ��Ӱ���ںϽ������������֮ǰ��¼�ĳߴ���Ϣ����ͼ���ں�λ�õĿ���
% iter: ƴ�ӵ�������������Խ�ߣ�ƴ��Ч��Խ��
%

used_img = [];
pano_image = image_list{1};

for ct_iter = 1:iter
    for ct = 2:length(image_list)
        stiching_area = corners(ct-1,3):corners(ct,5);
        for layer = 1:3
            pano_image(:,stiching_area,layer) = multi_blend(pano_image(:,stiching_area,layer), image_list{ct}(:,stiching_area,layer));    % ����uint8����ͼ��
        end
    end
end

% % �ظ��ںϣ�����ں϶�
% for ct = 2:length(filled_pano_image)
%     for layer = 1:3     % rgb
%         pano_image(:,:,layer) = multi_blend(pano_image(:,:,layer), filled_pano_image{ct}(:,:,layer));
%     end
% end

end

function  image = fill_images(image, image_list, corners, index_list)

for ct = 1:length(index_list)  
    num = index_list(ct);
    if num ~= 1   % ����ͬһ�������Կ�ʼ���
        image(:,corners(num-1, 3):corners(num, 3),:) = image_list{num}(:, corners(num-1, 3):corners(num, 3) ,:);
    else
        image(:,1:corners(num, 3),:) = image_list{num}(:, 1:corners(num, 3) ,:);
    end
end

end