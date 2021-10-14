% 第一种方式，比如240*240,先分6块，就是40*240,按4颜色分量，每块就是20*120
% 
% 
% 第二种是直接把240*240，分4颜色分量，就是120*120为一个最小单元来处理。
% 

% 第三种，就是把240*240，作为一个最小单元来处理。但是在每一行内部，会进行一些位置的调整，把相同颜色靠拢。在行与行之间，也会进行一些调整。
% 具体的调整，之前的任务安排中已经讲了
% bayer rgb,经过3的处理后，变成
% ggggrrrr
% ggggbbbb
% ggggrrrr
% ggggbbbb
% ggggrrrr
% ggggbbbb
% 经过4的处理后，缓存2行，是和3相同的。
% 缓存4行，结果如下：
% ggggrrrr
% ggggrrrr
% ggggbbbb
% ggggbbbb
% ggggrrrr
% ggggrrrr
% ggggbbbb
% ggggbbbb
% 把他们整体编码





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global bayerimage0 %这只是个用于计算PSNR的参数，实际使用时可以删除
code_index = 1;
load ans_code;

totaloutput='';%总体图像的输出
tmp = imread('sample3.bmp','bmp');
A0 =double(imread('sample3.bmp'));%载入图像，标准图像大小为x*y~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% 原始图片的一些指标
I1=tmp(:,:,1);        %R
I2=tmp(:,:,2);        %G
I3=tmp(:,:,3);        %B
[M,N]=size(I1);                      %将图像的行列赋值给M,N
figure;imshow(tmp);title('原始图片');
% figure;imhist(I1);title('原始图片R通道直方图');
figure;imhist(I2);title('原始图片G通道直方图');
% figure;imhist(I3);title('原始图片B通道直方图');

% %% 原始图片R,G,B通道信息熵
% %R通道
% T1_R=imhist(I1);   %统计图像R通道灰度值从0~255的分布情况，存至T1
% S1_R=sum(T1_R);     %计算整幅图像R通道的灰度值
% xxs1_R=0;           %原始图片R通道相关性
% %G通道
% T1_G=imhist(I2);
% S1_G=sum(T1_G);
% xxs1_G=0;
% %B通道
% T1_B=imhist(I3);
% S1_B=sum(T1_B);
% xxs1_B=0;
% 
% for i=1:256
%     pp1_R=T1_R(i)/S1_R;   %每个灰度值占比，即每个灰度值的概率
%     pp1_G=T1_G(i)/S1_G;
%     pp1_B=T1_B(i)/S1_B;
%     if pp1_R~=0
%         xxs1_R=xxs1_R-pp1_R*log2(pp1_R);
%     end
%     if pp1_G~=0
%         xxs1_G=xxs1_G-pp1_G*log2(pp1_G);
%     end
%     if pp1_B~=0
%         xxs1_B=xxs1_B-pp1_B*log2(pp1_B);
%     end
% end

%% 原始图像相邻像素相关性分析
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
    XX_R_SP(i)=I1(x1(i),y1(i));
    YY_R_SP(i)=I1(x1(i)+1,y1(i));
    XX_G_SP(i)=I2(x1(i),y1(i));
    YY_G_SP(i)=I2(x1(i)+1,y1(i));
    XX_B_SP(i)=I3(x1(i),y1(i));
    YY_B_SP(i)=I3(x1(i)+1,y1(i));
    %垂直
    XX_R_CZ(i)=I1(x1(i),y1(i));
    YY_R_CZ(i)=I1(x1(i),y1(i)+1);
    XX_G_CZ(i)=I2(x1(i),y1(i));
    YY_G_CZ(i)=I2(x1(i),y1(i)+1);
    XX_B_CZ(i)=I3(x1(i),y1(i));
    YY_B_CZ(i)=I3(x1(i),y1(i)+1);
    %对角线
    XX_R_DJX(i)=I1(x1(i),y1(i));
    YY_R_DJX(i)=I1(x1(i)+1,y1(i)+1);
    XX_G_DJX(i)=I2(x1(i),y1(i));
    YY_G_DJX(i)=I2(x1(i)+1,y1(i)+1);
    XX_B_DJX(i)=I3(x1(i),y1(i));
    YY_B_DJX(i)=I3(x1(i)+1,y1(i)+1);
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
figure;scatter(XX_R_DJX,YY_R_DJX,18,'filled');xlabel('R通道随机点像素灰度值');ylabel('与该点相邻对角线方向像素灰度值');title('原始图像R通道对角线相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_DJX,YY_G_DJX,18,'filled');xlabel('G通道随机点像素灰度值');ylabel('与该点相邻对角线方向像素灰度值');title('原始图像G通道对角线相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_DJX,YY_B_DJX,18,'filled');xlabel('B通道随机点像素灰度值');ylabel('与该点相邻对角线方向像素灰度值');title('原始图像B通道对角线相邻元素相关性点图');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% %R通道
% EX1_R=0;EY1_SP_R=0;DX1_R=0;DY1_SP_R=0;COVXY1_SP_R=0;    %计算水平相关性时需要的变量
% EY1_CZ_R=0;DY1_CZ_R=0;COVXY1_CZ_R=0;                %垂直
% EY1_DJX_R=0;DY1_DJX_R=0;COVXY1_DJX_R=0;             %对角线
% %G通道
% EX1_G=0;EY1_SP_G=0;DX1_G=0;DY1_SP_G=0;COVXY1_SP_G=0;
% EY1_CZ_G=0;DY1_CZ_G=0;COVXY1_CZ_G=0;
% EY1_DJX_G=0;DY1_DJX_G=0;COVXY1_DJX_G=0;
% %B通道
% EX1_B=0;EY1_SP_B=0;DX1_B=0;DY1_SP_B=0;COVXY1_SP_B=0;
% EY1_CZ_B=0;DY1_CZ_B=0;COVXY1_CZ_B=0;
% EY1_DJX_B=0;DY1_DJX_B=0;COVXY1_DJX_B=0;
% 
% I1=double(I1);
% I2=double(I2);
% I3=double(I3);
% for i=1:NN
%     %第一个像素点的E，水平、垂直、对角线时计算得出的第一个像素点的E相同，统一用EX1表示
%     EX1_R=EX1_R+I1(x1(i),y1(i)); 
%     EX1_G=EX1_G+I2(x1(i),y1(i)); 
%     EX1_B=EX1_B+I3(x1(i),y1(i)); 
%     %第二个像素点的E，水平、垂直、对角线的E分别对应EY1_SP、EY1_CZ、EY1_DJX
%     %R通道
%     EY1_SP_R=EY1_SP_R+I1(x1(i),y1(i)+1);
%     EY1_CZ_R=EY1_CZ_R+I1(x1(i)+1,y1(i));
%     EY1_DJX_R=EY1_DJX_R+I1(x1(i)+1,y1(i)+1);
%     %G通道
%     EY1_SP_G=EY1_SP_G+I2(x1(i),y1(i)+1);
%     EY1_CZ_G=EY1_CZ_G+I2(x1(i)+1,y1(i));
%     EY1_DJX_G=EY1_DJX_G+I2(x1(i)+1,y1(i)+1);
%     %B通道
%     EY1_SP_B=EY1_SP_B+I3(x1(i),y1(i)+1);
%     EY1_CZ_B=EY1_CZ_B+I3(x1(i)+1,y1(i));
%     EY1_DJX_B=EY1_DJX_B+I3(x1(i)+1,y1(i)+1);
% end
% %统一在循环外除以像素点对数1000，可减少运算次数
% % R通道
% EX1_R=EX1_R/NN;
% EY1_SP_R=EY1_SP_R/NN;
% EY1_CZ_R=EY1_CZ_R/NN;
% EY1_DJX_R=EY1_DJX_R/NN;
% % G通道
% EX1_G=EX1_G/NN;
% EY1_SP_G=EY1_SP_G/NN;
% EY1_CZ_G=EY1_CZ_G/NN;
% EY1_DJX_G=EY1_DJX_G/NN;
% % B通道
% EX1_B=EX1_B/NN;
% EY1_SP_B=EY1_SP_B/NN;
% EY1_CZ_B=EY1_CZ_B/NN;
% EY1_DJX_B=EY1_DJX_B/NN;
% for i=1:NN
%     %第一个像素点的D，水平、垂直、对角线时计算得出第一个像素点的D相同，统一用DX表示
%     DX1_R=DX1_R+(I1(x1(i),y1(i))-EX1_R)^2;
%     DX1_G=DX1_G+(I2(x1(i),y1(i))-EX1_G)^2;
%     DX1_B=DX1_B+(I3(x1(i),y1(i))-EX1_B)^2;
%     %第二个像素点的D，水平、垂直、对角线的D分别对应DY1_SP、DY1_CZ、DY1_DJX
%     %R通道
%     DY1_SP_R=DY1_SP_R+(I1(x1(i),y1(i)+1)-EY1_SP_R)^2;
%     DY1_CZ_R=DY1_CZ_R+(I1(x1(i)+1,y1(i))-EY1_CZ_R)^2;
%     DY1_DJX_R=DY1_DJX_R+(I1(x1(i)+1,y1(i)+1)-EY1_DJX_R)^2;
%     %G通道
%     DY1_SP_G=DY1_SP_G+(I2(x1(i),y1(i)+1)-EY1_SP_G)^2;
%     DY1_CZ_G=DY1_CZ_G+(I2(x1(i)+1,y1(i))-EY1_CZ_G)^2;
%     DY1_DJX_G=DY1_DJX_G+(I2(x1(i)+1,y1(i)+1)-EY1_DJX_G)^2;
%     %B通道
%     DY1_SP_B=DY1_SP_B+(I3(x1(i),y1(i)+1)-EY1_SP_B)^2;
%     DY1_CZ_B=DY1_CZ_B+(I3(x1(i)+1,y1(i))-EY1_CZ_B)^2;
%     DY1_DJX_B=DY1_DJX_B+(I3(x1(i)+1,y1(i)+1)-EY1_DJX_B)^2;
%     %两个相邻像素点相关函数的计算，水平、垂直、对角线
%     %R通道
%     COVXY1_SP_R=COVXY1_SP_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i),y1(i)+1)-EY1_SP_R);
%     COVXY1_CZ_R=COVXY1_CZ_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i)+1,y1(i))-EY1_CZ_R);
%     COVXY1_DJX_R=COVXY1_DJX_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i)+1,y1(i)+1)-EY1_DJX_R);
%     %G通道
%     COVXY1_SP_G=COVXY1_SP_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i),y1(i)+1)-EY1_SP_G);
%     COVXY1_CZ_G=COVXY1_CZ_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i)+1,y1(i))-EY1_CZ_G);
%     COVXY1_DJX_G=COVXY1_DJX_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i)+1,y1(i)+1)-EY1_DJX_G);
%     %B通道
%     COVXY1_SP_B=COVXY1_SP_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i),y1(i)+1)-EY1_SP_B);
%     COVXY1_CZ_B=COVXY1_CZ_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i)+1,y1(i))-EY1_CZ_B);
%     COVXY1_DJX_B=COVXY1_DJX_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i)+1,y1(i)+1)-EY1_DJX_B);
% end
% %统一在循环外除以像素点对数1000，可减少运算次数
% %R通道
% DX1_R=DX1_R/NN;
% DY1_SP_R=DY1_SP_R/NN;
% DY1_CZ_R=DY1_CZ_R/NN;
% DY1_DJX_R=DY1_DJX_R/NN;
% COVXY1_SP_R=COVXY1_SP_R/NN;
% COVXY1_CZ_R=COVXY1_CZ_R/NN;
% COVXY1_DJX_R=COVXY1_DJX_R/NN;
% %G通道
% DX1_G=DX1_G/NN;
% DY1_SP_G=DY1_SP_G/NN;
% DY1_CZ_G=DY1_CZ_G/NN;
% DY1_DJX_G=DY1_DJX_G/NN;
% COVXY1_SP_G=COVXY1_SP_G/NN;
% COVXY1_CZ_G=COVXY1_CZ_G/NN;
% COVXY1_DJX_G=COVXY1_DJX_G/NN;
% %B通道
% DX1_B=DX1_B/NN;
% DY1_SP_B=DY1_SP_B/NN;
% DY1_CZ_B=DY1_CZ_B/NN;
% DY1_DJX_B=DY1_DJX_B/NN;
% COVXY1_SP_B=COVXY1_SP_B/NN;
% COVXY1_CZ_B=COVXY1_CZ_B/NN;
% COVXY1_DJX_B=COVXY1_DJX_B/NN;
% %水平、垂直、对角线的相关性
% %R通道
% RXY1_SP_R=COVXY1_SP_R/sqrt(DX1_R*DY1_SP_R);
% RXY1_CZ_R=COVXY1_CZ_R/sqrt(DX1_R*DY1_CZ_R);
% RXY1_DJX_R=COVXY1_DJX_R/sqrt(DX1_R*DY1_DJX_R);
% %G通道
% RXY1_SP_G=COVXY1_SP_G/sqrt(DX1_G*DY1_SP_G);
% RXY1_CZ_G=COVXY1_CZ_G/sqrt(DX1_G*DY1_CZ_G);
% RXY1_DJX_G=COVXY1_DJX_G/sqrt(DX1_G*DY1_DJX_G);
% %B通道
% RXY1_SP_B=COVXY1_SP_B/sqrt(DX1_B*DY1_SP_B);
% RXY1_CZ_B=COVXY1_CZ_B/sqrt(DX1_B*DY1_CZ_B);
% RXY1_DJX_B=COVXY1_DJX_B/sqrt(DX1_B*DY1_DJX_B);




%% 编码部分
% load codebook_step4%载入码本，压缩步长为2.
% step=4;%量化步长
x=240;%图像的行数
y=240;%图像的列数
xx=40;%处理单元的行数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
yy=240;%处理单元的列数
z=0;%ROI起始行数
w=0;%ROI起始列数
% q=0;%ROI结束行数
% p=0;%ROI结束列数

%bayer彩色滤波阵列格式
%  B  G
%  G  R
filter(:,:,3)=[1 0;0 0];%bayer彩色滤波阵列b分量
filter(:,:,2)=[0 1;1 0];%bayer彩色滤波阵列g分量
filter(:,:,1)=[0 0;0 1];%bayer彩色滤波阵列r分量
% A0(1,1,1) = 1;  
%将普通GRB颜色照片转成BAYER格式照片
for i=1:x/2%行数，每个滤波阵列为2*2,图像有x行，所以需要循环120次
    for j=1:y/2%列数，循环160次
        A0(2*i-1:2*i,2*j-1:2*j,:)=A0(2*i-1:2*i,2*j-1:2*j,:).*filter;
    end
end

bayerimage0=A0;


temp=zeros(x,y,1);
temp=A0(:,:,1)+A0(:,:,2)+A0(:,:,3);
A0=temp;%A0变成转换好了的bayer照片，尺寸是x*y*1
clear temp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A0=round(A0/2);%对应于NEAR=1;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% A0=round(A0/4);%对应于NEAR=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%把bayer图像中个像素重新排列
temp1=zeros(1,y/2);
temp2=zeros(1,y/2);
for i=1:x%把每一行内的像素整理排列一下，绿色放左边，其他颜色颠倒顺序后放右边。颠倒顺序可以使不同颜色过渡那里平滑些。
    if mod(i,2)==1%如果是奇数行
        temp1=A0(i,1:2:y-1);%颜色B
        temp2=A0(i,2:2:y);%颜色G1
        A0(i,1:y/2)=temp2;%把G集中放在左边
        A0(i,(y/2)+1:end)=temp1(end:-1:1);%把其他颜色放右边。注意顺序倒过来，这样增加图片平滑性
    else
        temp1=A0(i,1:2:y-1);%颜色G2
        temp2=A0(i,2:2:y);%颜色R
        A0(i,1:y/2)=temp1;%把G集中放在左边
        A0(i,(y/2)+1:end)=temp2(end:-1:1);%把其他颜色放右边。注意顺序倒过来，这样增加图片平滑性
    end
end
clear temp1 temp2


for k=1:6 %把240*240的图像分成40*240的六块作为基本处理单元
    k
    A=A0(1+40*(k-1):40*k,:);
    
%     for i=2:yy%对基本处理图像单元（20*120的颜色分量图）进行水平滤波
%         A(:,i)=round((A(:,i-1)+A(:,i))/2);
%     end
% 
%     for i=2:xx%对基本处理图像单元（20*120的颜色分量图）进行水平滤波
%         A(i,:)=round((A(i-1,:)+A(i,:))/2);
%     end

    [JPEGLS_coderoutput1,JPEGLS_coderoutput2, code_index]=JPEGLS_coder(A, code_index, ans_code);
    totaloutput=strcat(totaloutput,JPEGLS_coderoutput1,JPEGLS_coderoutput2);
end

save totaloutput_k_test totaloutput;
%% 结果部分
TotalCompressionRatio = x*y*8/length(totaloutput);%总体压缩率
clear A JPEGLS_coderoutput1 JPEGLS_coderoutput2 n A1 Errorquant i j m filter A0_color step;

       
        