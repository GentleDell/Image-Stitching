function homography_mat = findHomography(feature_img1, feature_img2, index)
% ����������������ⵥӦ�Ծ���
% feature_img1/2: ͼ1ͼ2�ϵ�������λ�ã�

homo_fea1 = feature_img1(:,index);
homo_fea2 = feature_img2(:,index);
fea_mat = [];
fea_vec = [];

for ct = 1:length(index) % ��������
    x1 = homo_fea1(1,ct); y1 = homo_fea1(2,ct);
    x1_ = homo_fea2(1,ct); y1_ = homo_fea2(2,ct);
    temp_mat = [x1_, y1_, 1, 0, 0, 0, -x1*x1_, -x1*y1_, -x1;
                0, 0, 0, x1_, y1_, 1, -y1*x1_, -y1*y1_, -y1;];
    fea_mat = [fea_mat;temp_mat];
    fea_vec = [fea_vec; x1; y1];
end
if length(index) == 4
    if ~Linecheck( (reshape(fea_vec,2,4))' );    % ���ĵ㹲�ߣ����ؿվ���
        homography_mat = [];
        return;
    end
end

% �������ֵ����Ϊsingle�������ֳ����ƻᱨwarning(��������)��ת��Ϊdouble��ͺ���
% ʹ����С���˷�lsqnonneg()�������,�侫��Զ����linsolve(), A\b �Լ� inv(A)*b;
[homo_vec,~,~,exitflag,~] = lsqnonneg(double(fea_mat),double(fea_vec));

if ~exitflag    % δ���������ؿվ���
    homography_mat = [];
    return;
end

homography_mat = [homo_vec(1),homo_vec(2),homo_vec(3);
                  homo_vec(4),homo_vec(5),homo_vec(6);
                  homo_vec(7),homo_vec(8),    1     ];

end

function flag = Linecheck( feat_p )

linethreshold = 1e-6;  % ����������Ϊ���ߣ�ֵԽ��Լ������

A = feat_p(1,:) - feat_p(2,:);
B = feat_p(2,:) - feat_p(3,:);
C = feat_p(3,:) - feat_p(4,:);

if abs(det( [A; B]/max(max([A; B])) )) > linethreshold     % ǰ���㲻����
    flag = true;
elseif abs(det( [B; C]/max(max([B; C])) )) > linethreshold      % �����㲻����
    flag = true;
else                        % �ĵ㹲��
    flag = false;
end

end