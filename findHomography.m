function homography_mat = findHomography(feature_img1, feature_img2, index)
% 根据所给特征点求解单应性矩阵；
% feature_img1/2: 图1图2上的特征点位置；

homo_fea1 = feature_img1(:,index);
homo_fea2 = feature_img2(:,index);
fea_mat = [];
fea_vec = [];

for ct = 1:length(index) % 构建矩阵
    x1 = homo_fea1(1,ct); y1 = homo_fea1(2,ct);
    x1_ = homo_fea2(1,ct); y1_ = homo_fea2(2,ct);
    temp_mat = [x1_, y1_, 1, 0, 0, 0, -x1*x1_, -x1*y1_, -x1;
                0, 0, 0, x1_, y1_, 1, -y1*x1_, -y1*y1_, -y1;];
    fea_mat = [fea_mat;temp_mat];
    fea_vec = [fea_vec; x1; y1];
end
if length(index) == 4
    if ~Linecheck( (reshape(fea_vec,2,4))' );    % 若四点共线，返回空矩阵
        homography_mat = [];
        return;
    end
end

% 最初的数值类型为single，由于字长限制会报warning(矩阵奇异)，转换为double后就好了
% 使用最小二乘法lsqnonneg()函数求解,其精度远高于linsolve(), A\b 以及 inv(A)*b;
[homo_vec,~,~,exitflag,~] = lsqnonneg(double(fea_mat),double(fea_vec));

if ~exitflag    % 未收敛，返回空矩阵
    homography_mat = [];
    return;
end

homography_mat = [homo_vec(1),homo_vec(2),homo_vec(3);
                  homo_vec(4),homo_vec(5),homo_vec(6);
                  homo_vec(7),homo_vec(8),    1     ];

end

function flag = Linecheck( feat_p )

linethreshold = 1e-6;  % 超过门限认为共线，值越大约不共线

A = feat_p(1,:) - feat_p(2,:);
B = feat_p(2,:) - feat_p(3,:);
C = feat_p(3,:) - feat_p(4,:);

if abs(det( [A; B]/max(max([A; B])) )) > linethreshold     % 前三点不共线
    flag = true;
elseif abs(det( [B; C]/max(max([B; C])) )) > linethreshold      % 后三点不共线
    flag = true;
else                        % 四点共线
    flag = false;
end

end