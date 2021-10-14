%% 4.求解Chen氏超混沌系统
%求四个初值X0,Y0,Z0,H0
r=240 * 240;      %r为分块个数
SUM = 240 * 240;
tmp = imread('sample1.bmp','bmp');
A0 =double(imread('sample1.bmp'));%载入图像，标准图像大小为x*y~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% 原始图片的一些指标
I1=tmp(:,:,1);        %R
I2=tmp(:,:,2);        %G
I3=tmp(:,:,3);        %B


%求出四个初值
X0=sum(sum(bitand(I1,17)))/(17*SUM);
Y0=sum(sum(bitand(I2,34)))/(34*SUM);
Z0=sum(sum(bitand(I3,68)))/(68*SUM);
H0=sum(sum(bitand(I1,136)))/(136*SUM);
%保留四位小数
X0=round(X0*10^4)/10^4;
Y0=round(Y0*10^4)/10^4;
Z0=round(Z0*10^4)/10^4;
H0=round(H0*10^4)/10^4;
%根据初值，求解Chen氏超混沌系统，得到四个混沌序列
A=chen_output(X0,Y0,Z0,H0,r);   
X=A(:,1);
X=X(3002:length(X));        %去除前3001项，获得更好的随机性（求解陈氏系统的子函数多计算了3000点）
Y=A(:,2);
Y=Y(3002:length(Y));
Z=A(:,3);
Z=Z(3002:length(Z));
H=A(:,4);
H=H(3002:length(H));

figure
plot3(X,Y,Z);
xlabel('\itx');
ylabel('\ity');
zlabel('\itz');

figure
plot3(X,Y,H);
xlabel('\itx');
ylabel('\ity');
zlabel('\ith');

figure
plot3(H,Y,Z);
xlabel('\ith');
ylabel('\ity');
zlabel('\itz');

figure
plot3(X,H,Z);
xlabel('\itx');
ylabel('\ith');
zlabel('\itz');



%% 量化





%% 混沌组合
% 四维组合的 和 单独四维，共5个密钥，用于不同的加密点方法中
% 其中初值都是根据不同图像来的
total_code = zeros(1, 230400 - 4 * 3000);
tmp_code = zeros(1, 230400 - 4 * 3000);
ans_code = zeros(1, 230400 - 4 * 3000);
for i = 1 : 240 * 240 - 3000
    tmp_code(i) = H(i);
end
for i = 1 : 240 * 240 - 3000
    tmp_code(i + 240 * 240 - 3000) = X(i);
end
for i = 1 : 240 * 240 - 3000
    tmp_code(i + 2 * 240 * 240 - 2 * 3000) = Y(i);
end
for i = 1 : 240 * 240 - 3000
    tmp_code(i + 3 * 240 * 240 - 3 * 3000) = Z(i);
end

S = zeros(1, 4 * 240 * 240 - 4 * 3000);
T = zeros(1, 4 * 240 * 240 - 4 * 3000);
for i = 1 : 4 * 240 * 240 - 4 * 3000
    S(i) = i;
    T(i) = i;
end
j = 0;
for i = 1 : 4 * 240 * 240 - 4 * 3000
    j = mod(j + S(i), 4 * 240 * 240 - 4 * 3000) + 1;
    tmp = T(i);
    T(i) = T(j);
    T(j) = tmp;
end
j = 0;
%测试一下0，1分布
cnt0 = 0;
cnt1 = 0;
for i = 1 : 4 * 240 * 240 - 4 * 3000    
    j = mod(j + S(i) + T(i), 4 * 240 * 240 - 4 * 3000) + 1;
    total_code(i) = tmp_code(j);
    if total_code(i) >= 12.6 || total_code(i) <= -9
        ans_code(i) = 0;
        cnt0 = cnt0 + 1;
    else
        ans_code(i) = 1;
        cnt1 = cnt1 + 1;
    end
end
save ans_code ans_code;
clear A A0 i I1 I2 I3 j r s SUM tmp;



