function [pano_image] = Image_Stitching(image_list, corners, iter)
%% Image stitching with multiple band blending
% image_list:拼接图像列表
% corners: 尺寸信息：左上左上右下; —— 图多的话其他地方的黑色会影响融合结果，所以利用之前记录的尺寸信息进行图像融合位置的控制
% iter: 拼接迭代次数，次数越高，拼接效果越好
%

used_img = [];
pano_image = image_list{1};

for ct_iter = 1:iter
    for ct = 2:length(image_list)
        stiching_area = corners(ct-1,3):corners(ct,5);
        for layer = 1:3
            pano_image(:,stiching_area,layer) = multi_blend(pano_image(:,stiching_area,layer), image_list{ct}(:,stiching_area,layer));    % 返回uint8单层图像
        end
    end
end

% % 重复融合，提高融合度
% for ct = 2:length(filled_pano_image)
%     for layer = 1:3     % rgb
%         pano_image(:,:,layer) = multi_blend(pano_image(:,:,layer), filled_pano_image{ct}(:,:,layer));
%     end
% end

end

function  image = fill_images(image, image_list, corners, index_list)

for ct = 1:length(index_list)  
    num = index_list(ct);
    if num ~= 1   % 不是同一幅，可以开始填充
        image(:,corners(num-1, 3):corners(num, 3),:) = image_list{num}(:, corners(num-1, 3):corners(num, 3) ,:);
    else
        image(:,1:corners(num, 3),:) = image_list{num}(:, 1:corners(num, 3) ,:);
    end
end

end