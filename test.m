clear; close;

pa = repmat([0 .0],[4097,1]);
pb = [100*ones(4097,1),(-2048:2048)'];

delta_dis = pb - pa;
thita = atan2(delta_dis(:,2),delta_dis(:,1));
plot(thita);