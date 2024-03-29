%按照6x40的大小依次读取图像的各个部分
%图像大小为x*y,共读取48次

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global bayerimage0 
% load codebook_step1%载入码本
% step=1;%压缩步长为2
x=240;%图像的行数
y=240;%图像的列数
xx=40;%处理单元的行数
yy=240;%处理单元的列数
z=0;%ROI起始行数
w=0;%ROI起始列数
% q=0;%ROI结束行数
% p=0;%ROI结束列数
code_index = 1;
load ans_code;

t0=cputime;%开始计时



%%
for k=1:6
    k
    [Re_A,totaloutput, code_index]=JPEGLS_decoder(totaloutput, code_index, ans_code);
%     for i=xx:-1:2%对彩色分量图进行垂直逆滤波
%         Re_A(i,:)=2*Re_A(i,:)-Re_A(i-1,:);
%     end
%         
%     for i=yy:-1:2%对彩色分量图进行水平逆滤波
%         Re_A(:,i)=2*Re_A(:,i)-Re_A(:,i-1);
%     end
    
    Re_A0(1+40*(k-1):40*k,:)=Re_A;%图像的解码
end

time=cputime-t0%计时结束

clear  t0 time

        




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%将排列后的bayer图回复成正常的BAYER格式图像
%预处理中把bayer图像中个像素重新排列
%现在逆操作
temp1=zeros(1,y/2);
temp2=zeros(1,y/2);
for i=1:x%把每一行内的像素整理排列一下，绿色放左边，其他颜色颠倒顺序后放右边。现在逆操作。
    if mod(i,2)==1%如果是奇数行
        temp1=Re_A0(i,1:y/2);%颜色G1
        temp2=Re_A0(i,(y/2)+1:end);%颜色B
        Re_A0(i,1:2:y-1)=temp2(end:-1:1);%把B颠倒顺序后放在奇数列
        Re_A0(i,2:2:y)=temp1;%把G1放在偶数列
    else
        temp1=Re_A0(i,1:y/2);%颜色G2
        temp2=Re_A0(i,(y/2)+1:end);%颜色R
        Re_A0(i,1:2:y-1)=temp1;%把G2集中放在奇数列
        Re_A0(i,2:2:y)=temp2(end:-1:1);%把R放在偶数列
    end
end











save Re_A0_k_test Re_A0;
clear temp1 temp2

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%将普通bayer照片转成三个颜色层的准RGB格式
tempRe_A0=zeros(x,y,3);
for i=1:x
    for j=1:y%列数
        if (mod(i,2)==1) && (mod(j,2)==1)
            tempRe_A0(i,j,3)=Re_A0(i,j);%B分量放到第3层
        else
            if (mod(i,2)==0) && (mod(j,2)==0)
                tempRe_A0(i,j,1)=Re_A0(i,j);%R分量放到第1层
            else
                tempRe_A0(i,j,2)=Re_A0(i,j);%G分量放到第2层
            end
        end
    end
end

Re_A0=tempRe_A0;
% figure;imhist(Re_A0(:,:,2));title('加密图片通道直方图');
% clear tempRe_A0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Re_A0=Re_A0*2;%对应于NEAR=1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Re_A0=Re_A0*4;%对应于NEAR=2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
subplot(2,2,3),subimage(uint8(Re_A0)),title('恢复BAYER图像Re_A0')


bayerimage1=Re_A0;%计算PSNR用的参数，实际使用时可删除



%对BAYER格式照片进行插值，恢复成为RGB颜色照片
for i=2:2:x-2
    Re_A0(i,:,3)=(Re_A0(i-1,:,3)+Re_A0(i+1,:,3))/2;
end
Re_A0(x,:,3)=Re_A0(x-1,:,3);

for i=2:2:y-2
    Re_A0(:,i,3)=(Re_A0(:,i-1,3)+Re_A0(:,i+1,3))/2;
end
Re_A0(:,y,3)=Re_A0(:,y-1,3);       %将Re_A0照片中B分量插值恢复


for i=3:2:x-1
    Re_A0(i,:,1)=(Re_A0(i-1,:,1)+Re_A0(i+1,:,1))/2;
end
Re_A0(1,:,1)=Re_A0(2,:,1);

for i=3:2:y-1
    Re_A0(:,i,1)=(Re_A0(:,i-1,1)+Re_A0(:,i+1,1))/2;
end
Re_A0(:,1,1)=Re_A0(:,2,1);           %将Re_A0照片中R分量插值恢复

Re_A0(1,1,2)=(Re_A0(2,1,2)+Re_A0(1,2,2))/2;
Re_A0(x,y,2)=(Re_A0(x,y-1,2)+Re_A0(x-1,y,2))/2;
for i=2:x-1
    if Re_A0(i,1,2)==0
        Re_A0(i,1,2)=(Re_A0(i+1,1,2)+Re_A0(i,2,2))/2;
    end
    if Re_A0(i,y,2)==0
        Re_A0(i,y,2)=(Re_A0(i-1,y,2)+Re_A0(i,y-1,2))/2;
    end
end
for j=2:y-1
    if Re_A0(1,j,2)==0
        Re_A0(1,j,2)=(Re_A0(2,j,2)+Re_A0(1,j+1,2))/2;
    end
    if Re_A0(x,j,2)==0
        Re_A0(x,j,2)=(Re_A0(x-1,j,2)+Re_A0(x,j-1,2))/2;
    end
end
for i=2:x-1
    for j=2:y-1
        if Re_A0(i,j,2)==0
            Re_A0(i,j,2)=(Re_A0(i+1,j,2)+Re_A0(i,j+1,2)+Re_A0(i-1,j,2)+Re_A0(i,j-1,2))/4;
        end
    end
end %将Re_A0照片中G分量插值恢复


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%画图，计算PSNR
A0=imread('sample3.bmp');%载入图像，标准图像大小为x*y~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
subplot(2,2,2),subimage(A0),title('原始RGB图像A0')
Re_A0=uint8(Re_A0);%处理过程中将图像像素元素改成double精度，最后处理完了需要转换回uint8模式
subplot(2,2,4),subimage(Re_A0),title('恢复RGB图像Re_A0')

A0_1D=zeros(1,x*y*3);%图像A0的一维输出
count=1;
for k=1:3
    for i=1:x %i表示图像上某像素的行数
        for j=1:y %j表示图像上某像素的列数
            A0_1D(count)=bayerimage0(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
            count=count+1;                %Errorquant_1D是一维数组
        end
    end
end

Re_A0_1D=zeros(1,x*y*3);%恢复图像Re_A0的一维输出
count=1;
for k=1:3
    for i=1:x %i表示图像上某像素的行数
        for j=1:y %j表示图像上某像素的列数
            Re_A0_1D(count)=bayerimage1(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
            count=count+1;                %Errorquant_1D是一维数组
        end
    end
end
MSE=sum((A0_1D-Re_A0_1D).^2)/length(A0_1D);
PSNR=10*log10((2^8-1)^2/MSE)%峰值信噪比
subplot(2,2,1),subimage(uint8(bayerimage0)),title('原始BAYER图像A0')
% clear A0_1D Re_A0_1D count i j k MSE Re_A n totaloutput A0 Re_A0 A0_color Re_A0_color filter m;


% 图像信息统计
I11=Re_A0(:,:,1);        %R
I22=Re_A0(:,:,2);        %G
I33=Re_A0(:,:,3);        %B
figure;imhist(I11);title('加密图片R通道直方图');
figure;imhist(I22);title('加密图片G通道直方图');
figure;imhist(I33);title('加密图片B通道直方图');



%{
先随机在0~M-1行和0~N-1列选中5000个像素点，
计算水平相关性时，选择每个点的相邻的右边的点；
计算垂直相关性时，选择每个点的相邻的下方的点；
计算对角线相关性时，选择每个点的相邻的右下方的点。
%}
NN=5000;    %随机取5000对像素点
x1=ceil(rand(1,NN)*(M-1));      %生成5000个1~M-1的随机整数作为行
y1=ceil(rand(1,NN)*(N-1));      %生成5000个1~N-1的随机整数作为列
%预分配内存
XX_R_SP=zeros(1,NN);YY_R_SP=zeros(1,NN);        %水平
XX_G_SP=zeros(1,NN);YY_G_SP=zeros(1,NN);
XX_B_SP=zeros(1,NN);YY_B_SP=zeros(1,NN);
XX_R_CZ=zeros(1,NN);YY_R_CZ=zeros(1,NN);        %垂直
XX_G_CZ=zeros(1,NN);YY_G_CZ=zeros(1,NN);
XX_B_CZ=zeros(1,NN);YY_B_CZ=zeros(1,NN);
XX_R_DJX=zeros(1,NN);YY_R_DJX=zeros(1,NN);      %对角线
XX_G_DJX=zeros(1,NN);YY_G_DJX=zeros(1,NN);
XX_B_DJX=zeros(1,NN);YY_B_DJX=zeros(1,NN);
for i=1:NN
    %水平
    XX_R_SP(i)=I11(x1(i),y1(i));
    YY_R_SP(i)=I11(x1(i)+1,y1(i));
    XX_G_SP(i)=I22(x1(i),y1(i));
    YY_G_SP(i)=I22(x1(i)+1,y1(i));
    XX_B_SP(i)=I33(x1(i),y1(i));
    YY_B_SP(i)=I33(x1(i)+1,y1(i));
    %垂直
    XX_R_CZ(i)=I11(x1(i),y1(i));
    YY_R_CZ(i)=I11(x1(i),y1(i)+1);
    XX_G_CZ(i)=I22(x1(i),y1(i));
    YY_G_CZ(i)=I22(x1(i),y1(i)+1);
    XX_B_CZ(i)=I33(x1(i),y1(i));
    YY_B_CZ(i)=I33(x1(i),y1(i)+1);
    %对角线
    XX_R_DJX(i)=I11(x1(i),y1(i));
    YY_R_DJX(i)=I11(x1(i)+1,y1(i)+1);
    XX_G_DJX(i)=I22(x1(i),y1(i));
    YY_G_DJX(i)=I22(x1(i)+1,y1(i)+1);
    XX_B_DJX(i)=I33(x1(i),y1(i));
    YY_B_DJX(i)=I33(x1(i)+1,y1(i)+1);
end
% %水平
% figure;scatter(XX_R_SP,YY_R_SP,18,'filled');xlabel('R通道随机点像素灰度值');ylabel('与该点相邻水平方向像素灰度值');title('原始图像R通道水平相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% figure;scatter(XX_G_SP,YY_G_SP,18,'filled');xlabel('G通道随机点像素灰度值');ylabel('与该点相邻水平方向像素灰度值');title('原始图像G通道水平相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% figure;scatter(XX_B_SP,YY_B_SP,18,'filled');xlabel('B通道随机点像素灰度值');ylabel('与该点相邻水平方向像素灰度值');title('原始图像B通道水平相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% %垂直
% figure;scatter(XX_R_CZ,YY_R_CZ,18,'filled');xlabel('R通道随机点像素灰度值');ylabel('与该点相邻垂直方向像素灰度值');title('原始图像R通道垂直相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% figure;scatter(XX_G_CZ,YY_G_CZ,18,'filled');xlabel('G通道随机点像素灰度值');ylabel('与该点相邻垂直方向像素灰度值');title('原始图像G通道垂直相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% figure;scatter(XX_B_CZ,YY_B_CZ,18,'filled');xlabel('B通道随机点像素灰度值');ylabel('与该点相邻垂直方向像素灰度值');title('原始图像B通道垂直相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% %对角线
figure;scatter(XX_R_DJX,YY_R_DJX,18,'filled');xlabel('R通道随机点像素灰度值');ylabel('与该点相邻对角线方向像素灰度值');title('加密图像R通道对角线相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_DJX,YY_G_DJX,18,'filled');xlabel('G通道随机点像素灰度值');ylabel('与该点相邻对角线方向像素灰度值');title('加密图像G通道对角线相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_DJX,YY_B_DJX,18,'filled');xlabel('B通道随机点像素灰度值');ylabel('与该点相邻对角线方向像素灰度值');title('加密图像B通道对角线相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% %R通道

