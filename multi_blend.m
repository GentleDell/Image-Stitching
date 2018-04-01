function C = multi_blend(A, B)
% from internet: https://blog.csdn.net/ccblogger/article/details/70665552

%resize A,B,C to the same size¡ª¡ªunreasonable,should be adaptive
% A_size = size(A);
% B_size = size(B);
% C_size = [512,512,3];
% if(sum(A_size ~= C_size))
%     A = imresize(A,C_size(1:2));
% end
% if(sum(B_size ~= C_size))
%     B = imresize(B,C_size(1:2));
% end

A = im2double(A);
B = im2double(B);

%gaussian kernel
kernel=fspecial('gaussian',[5 5],1);

%obtain the Gauss Pyramid
G_A0 = A;
G_A1 = conv2(G_A0,kernel,'same');
G_A1 = G_A1(2:2:size(G_A1,1),2:2:size(G_A1,2));
G_A2 = conv2(G_A1,kernel,'same');
G_A2 = G_A2(2:2:size(G_A2,1),2:2:size(G_A2,2));
G_A3 = conv2(G_A2,kernel,'same');
G_A3 = G_A3(2:2:size(G_A3,1),2:2:size(G_A3,2));
G_A4 = conv2(G_A3,kernel,'same');
G_A4 = G_A4(2:2:size(G_A4,1),2:2:size(G_A4,2));
G_A5 = conv2(G_A4,kernel,'same');
G_A5 = G_A5(2:2:size(G_A5,1),2:2:size(G_A5,2));

G_B0 = B;
G_B1 = conv2(G_B0,kernel,'same');
G_B1 = G_B1(2:2:size(G_B1,1),2:2:size(G_B1,2));
G_B2 = conv2(G_B1,kernel,'same');
G_B2 = G_B2(2:2:size(G_B2,1),2:2:size(G_B2,2));
G_B3 = conv2(G_B2,kernel,'same');
G_B3 = G_B3(2:2:size(G_B3,1),2:2:size(G_B3,2));
G_B4 = conv2(G_B3,kernel,'same');
G_B4 = G_B4(2:2:size(G_B4,1),2:2:size(G_B4,2));
G_B5 = conv2(G_B4,kernel,'same');
G_B5 = G_B5(2:2:size(G_B5,1),2:2:size(G_B5,2));

%get Laplacian Pyramid
L_A0 = double(G_A0)-imresize(G_A1,size(G_A0));
L_A1 = double(G_A1)-imresize(G_A2,size(G_A1));
L_A2 = double(G_A2)-imresize(G_A3,size(G_A2));
L_A3 = double(G_A3)-imresize(G_A4,size(G_A3));
L_A4 = double(G_A4)-imresize(G_A5,size(G_A4));
L_A5 = double(G_A5);

L_B0 = double(G_B0)-imresize(G_B1,size(G_B0));
L_B1 = double(G_B1)-imresize(G_B2,size(G_B1));
L_B2 = double(G_B2)-imresize(G_B3,size(G_B2));
L_B3 = double(G_B3)-imresize(G_B4,size(G_B3));
L_B4 = double(G_B4)-imresize(G_B5,size(G_B4));
L_B5 = double(G_B5);

%construct the mask
size0 = size(L_A0);
mask0 = zeros(size0);
mask0(:,1:round(size0(2)/2))=1;
mask0(:,round(size0(2)/2)-5:1:round(size0(2)/2)+5)=repmat(1:-0.1:0,[size0(1) 1]);
size1 = size(L_A1);
mask1 = zeros(size1);
mask1(:,1:round(size1(2)/2))=1;
mask1(:,round(size1(2)/2)-5:1:round(size1(2)/2)+5)=repmat(1:-0.1:0,[size1(1) 1]);
size2 = size(L_A2);
mask2 = zeros(size2);
mask2(:,1:round(size2(2)/2))=1;
mask2(:,round(size2(2)/2)-5:1:round(size2(2)/2)+5)=repmat(1:-0.1:0,[size2(1) 1]);
size3 = size(L_A3);
mask3 = zeros(size3);
mask3(:,1:round(size3(2)/2))=1;
mask3(:,round(size3(2)/2)-5:1:round(size3(2)/2)+5)=repmat(1:-0.1:0,[size3(1) 1]);
size4 = size(L_A4);
mask4 = zeros(size4);
mask4(:,1:round(size4(2)/2))=1;
mask4(:,round(size4(2)/2)-5:1:round(size4(2)/2)+5)=repmat(1:-0.1:0,[size4(1) 1]);
size5 = size(L_A5);
mask5 = zeros(size5);
mask5(:,1:round(size5(2)/2))=1;
mask5(:,round(size5(2)/2)-5:1: round(size5(2)/2)+5)=repmat(1:-0.1:0,[size5(1) 1]);

%obtain the output
L_C0 = L_A0 .* mask0 + L_B0 .* (1-mask0);
L_C1 = L_A1 .* mask1 + L_B1 .* (1-mask1);
L_C2 = L_A2 .* mask2 + L_B2 .* (1-mask2);
L_C3 = L_A3 .* mask3 + L_B3 .* (1-mask3);
L_C4 = L_A4 .* mask4 + L_B4 .* (1-mask4);
L_C5 = L_A5 .* mask5 + L_B5 .* (1-mask5);
C = L_C0+imresize(L_C1,size0)+imresize(L_C2,size0)+imresize(L_C3,size0)+imresize(L_C4,size0)+imresize(L_C5,size0);

C = uint8(C * 255);

% figure;
% imshow(C);

end