% ��һ�ַ�ʽ������240*240,�ȷ�6�飬����40*240,��4��ɫ������ÿ�����20*120
% 
% 
% �ڶ�����ֱ�Ӱ�240*240����4��ɫ����������120*120Ϊһ����С��Ԫ������
% 

% �����֣����ǰ�240*240����Ϊһ����С��Ԫ������������ÿһ���ڲ��������һЩλ�õĵ���������ͬ��ɫ��£����������֮�䣬Ҳ�����һЩ������
% ����ĵ�����֮ǰ�����������Ѿ�����
% bayer rgb,����3�Ĵ���󣬱��
% ggggrrrr
% ggggbbbb
% ggggrrrr
% ggggbbbb
% ggggrrrr
% ggggbbbb
% ����4�Ĵ���󣬻���2�У��Ǻ�3��ͬ�ġ�
% ����4�У�������£�
% ggggrrrr
% ggggrrrr
% ggggbbbb
% ggggbbbb
% ggggrrrr
% ggggrrrr
% ggggbbbb
% ggggbbbb
% �������������





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global bayerimage0 %��ֻ�Ǹ����ڼ���PSNR�Ĳ�����ʵ��ʹ��ʱ����ɾ��
code_index = 1;
load ans_code;

totaloutput='';%����ͼ������
tmp = imread('sample3.bmp','bmp');
A0 =double(imread('sample3.bmp'));%����ͼ�񣬱�׼ͼ���СΪx*y~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% ԭʼͼƬ��һЩָ��
I1=tmp(:,:,1);        %R
I2=tmp(:,:,2);        %G
I3=tmp(:,:,3);        %B
[M,N]=size(I1);                      %��ͼ������и�ֵ��M,N
figure;imshow(tmp);title('ԭʼͼƬ');
% figure;imhist(I1);title('ԭʼͼƬRͨ��ֱ��ͼ');
figure;imhist(I2);title('ԭʼͼƬGͨ��ֱ��ͼ');
% figure;imhist(I3);title('ԭʼͼƬBͨ��ֱ��ͼ');

% %% ԭʼͼƬR,G,Bͨ����Ϣ��
% %Rͨ��
% T1_R=imhist(I1);   %ͳ��ͼ��Rͨ���Ҷ�ֵ��0~255�ķֲ����������T1
% S1_R=sum(T1_R);     %��������ͼ��Rͨ���ĻҶ�ֵ
% xxs1_R=0;           %ԭʼͼƬRͨ�������
% %Gͨ��
% T1_G=imhist(I2);
% S1_G=sum(T1_G);
% xxs1_G=0;
% %Bͨ��
% T1_B=imhist(I3);
% S1_B=sum(T1_B);
% xxs1_B=0;
% 
% for i=1:256
%     pp1_R=T1_R(i)/S1_R;   %ÿ���Ҷ�ֵռ�ȣ���ÿ���Ҷ�ֵ�ĸ���
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

%% ԭʼͼ��������������Է���
%{
�������0~M-1�к�0~N-1��ѡ��5000�����ص㣬
����ˮƽ�����ʱ��ѡ��ÿ��������ڵ��ұߵĵ㣻
���㴹ֱ�����ʱ��ѡ��ÿ��������ڵ��·��ĵ㣻
����Խ��������ʱ��ѡ��ÿ��������ڵ����·��ĵ㡣
%}
NN=5000;    %���ȡ5000�����ص�
x1=ceil(rand(1,NN)*(M-1));      %����5000��1~M-1�����������Ϊ��
y1=ceil(rand(1,NN)*(N-1));      %����5000��1~N-1�����������Ϊ��
%Ԥ�����ڴ�
XX_R_SP=zeros(1,NN);YY_R_SP=zeros(1,NN);        %ˮƽ
XX_G_SP=zeros(1,NN);YY_G_SP=zeros(1,NN);
XX_B_SP=zeros(1,NN);YY_B_SP=zeros(1,NN);
XX_R_CZ=zeros(1,NN);YY_R_CZ=zeros(1,NN);        %��ֱ
XX_G_CZ=zeros(1,NN);YY_G_CZ=zeros(1,NN);
XX_B_CZ=zeros(1,NN);YY_B_CZ=zeros(1,NN);
XX_R_DJX=zeros(1,NN);YY_R_DJX=zeros(1,NN);      %�Խ���
XX_G_DJX=zeros(1,NN);YY_G_DJX=zeros(1,NN);
XX_B_DJX=zeros(1,NN);YY_B_DJX=zeros(1,NN);
for i=1:NN
    %ˮƽ
    XX_R_SP(i)=I1(x1(i),y1(i));
    YY_R_SP(i)=I1(x1(i)+1,y1(i));
    XX_G_SP(i)=I2(x1(i),y1(i));
    YY_G_SP(i)=I2(x1(i)+1,y1(i));
    XX_B_SP(i)=I3(x1(i),y1(i));
    YY_B_SP(i)=I3(x1(i)+1,y1(i));
    %��ֱ
    XX_R_CZ(i)=I1(x1(i),y1(i));
    YY_R_CZ(i)=I1(x1(i),y1(i)+1);
    XX_G_CZ(i)=I2(x1(i),y1(i));
    YY_G_CZ(i)=I2(x1(i),y1(i)+1);
    XX_B_CZ(i)=I3(x1(i),y1(i));
    YY_B_CZ(i)=I3(x1(i),y1(i)+1);
    %�Խ���
    XX_R_DJX(i)=I1(x1(i),y1(i));
    YY_R_DJX(i)=I1(x1(i)+1,y1(i)+1);
    XX_G_DJX(i)=I2(x1(i),y1(i));
    YY_G_DJX(i)=I2(x1(i)+1,y1(i)+1);
    XX_B_DJX(i)=I3(x1(i),y1(i));
    YY_B_DJX(i)=I3(x1(i)+1,y1(i)+1);
end
% %ˮƽ
% figure;scatter(XX_R_SP,YY_R_SP,18,'filled');xlabel('Rͨ����������ػҶ�ֵ');ylabel('��õ�����ˮƽ�������ػҶ�ֵ');title('ԭʼͼ��Rͨ��ˮƽ����Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% figure;scatter(XX_G_SP,YY_G_SP,18,'filled');xlabel('Gͨ����������ػҶ�ֵ');ylabel('��õ�����ˮƽ�������ػҶ�ֵ');title('ԭʼͼ��Gͨ��ˮƽ����Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% figure;scatter(XX_B_SP,YY_B_SP,18,'filled');xlabel('Bͨ����������ػҶ�ֵ');ylabel('��õ�����ˮƽ�������ػҶ�ֵ');title('ԭʼͼ��Bͨ��ˮƽ����Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% %��ֱ
% figure;scatter(XX_R_CZ,YY_R_CZ,18,'filled');xlabel('Rͨ����������ػҶ�ֵ');ylabel('��õ����ڴ�ֱ�������ػҶ�ֵ');title('ԭʼͼ��Rͨ����ֱ����Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% figure;scatter(XX_G_CZ,YY_G_CZ,18,'filled');xlabel('Gͨ����������ػҶ�ֵ');ylabel('��õ����ڴ�ֱ�������ػҶ�ֵ');title('ԭʼͼ��Gͨ����ֱ����Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% figure;scatter(XX_B_CZ,YY_B_CZ,18,'filled');xlabel('Bͨ����������ػҶ�ֵ');ylabel('��õ����ڴ�ֱ�������ػҶ�ֵ');title('ԭʼͼ��Bͨ����ֱ����Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% %�Խ���
figure;scatter(XX_R_DJX,YY_R_DJX,18,'filled');xlabel('Rͨ����������ػҶ�ֵ');ylabel('��õ����ڶԽ��߷������ػҶ�ֵ');title('ԭʼͼ��Rͨ���Խ�������Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_DJX,YY_G_DJX,18,'filled');xlabel('Gͨ����������ػҶ�ֵ');ylabel('��õ����ڶԽ��߷������ػҶ�ֵ');title('ԭʼͼ��Gͨ���Խ�������Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_DJX,YY_B_DJX,18,'filled');xlabel('Bͨ����������ػҶ�ֵ');ylabel('��õ����ڶԽ��߷������ػҶ�ֵ');title('ԭʼͼ��Bͨ���Խ�������Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% %Rͨ��
% EX1_R=0;EY1_SP_R=0;DX1_R=0;DY1_SP_R=0;COVXY1_SP_R=0;    %����ˮƽ�����ʱ��Ҫ�ı���
% EY1_CZ_R=0;DY1_CZ_R=0;COVXY1_CZ_R=0;                %��ֱ
% EY1_DJX_R=0;DY1_DJX_R=0;COVXY1_DJX_R=0;             %�Խ���
% %Gͨ��
% EX1_G=0;EY1_SP_G=0;DX1_G=0;DY1_SP_G=0;COVXY1_SP_G=0;
% EY1_CZ_G=0;DY1_CZ_G=0;COVXY1_CZ_G=0;
% EY1_DJX_G=0;DY1_DJX_G=0;COVXY1_DJX_G=0;
% %Bͨ��
% EX1_B=0;EY1_SP_B=0;DX1_B=0;DY1_SP_B=0;COVXY1_SP_B=0;
% EY1_CZ_B=0;DY1_CZ_B=0;COVXY1_CZ_B=0;
% EY1_DJX_B=0;DY1_DJX_B=0;COVXY1_DJX_B=0;
% 
% I1=double(I1);
% I2=double(I2);
% I3=double(I3);
% for i=1:NN
%     %��һ�����ص��E��ˮƽ����ֱ���Խ���ʱ����ó��ĵ�һ�����ص��E��ͬ��ͳһ��EX1��ʾ
%     EX1_R=EX1_R+I1(x1(i),y1(i)); 
%     EX1_G=EX1_G+I2(x1(i),y1(i)); 
%     EX1_B=EX1_B+I3(x1(i),y1(i)); 
%     %�ڶ������ص��E��ˮƽ����ֱ���Խ��ߵ�E�ֱ��ӦEY1_SP��EY1_CZ��EY1_DJX
%     %Rͨ��
%     EY1_SP_R=EY1_SP_R+I1(x1(i),y1(i)+1);
%     EY1_CZ_R=EY1_CZ_R+I1(x1(i)+1,y1(i));
%     EY1_DJX_R=EY1_DJX_R+I1(x1(i)+1,y1(i)+1);
%     %Gͨ��
%     EY1_SP_G=EY1_SP_G+I2(x1(i),y1(i)+1);
%     EY1_CZ_G=EY1_CZ_G+I2(x1(i)+1,y1(i));
%     EY1_DJX_G=EY1_DJX_G+I2(x1(i)+1,y1(i)+1);
%     %Bͨ��
%     EY1_SP_B=EY1_SP_B+I3(x1(i),y1(i)+1);
%     EY1_CZ_B=EY1_CZ_B+I3(x1(i)+1,y1(i));
%     EY1_DJX_B=EY1_DJX_B+I3(x1(i)+1,y1(i)+1);
% end
% %ͳһ��ѭ����������ص����1000���ɼ����������
% % Rͨ��
% EX1_R=EX1_R/NN;
% EY1_SP_R=EY1_SP_R/NN;
% EY1_CZ_R=EY1_CZ_R/NN;
% EY1_DJX_R=EY1_DJX_R/NN;
% % Gͨ��
% EX1_G=EX1_G/NN;
% EY1_SP_G=EY1_SP_G/NN;
% EY1_CZ_G=EY1_CZ_G/NN;
% EY1_DJX_G=EY1_DJX_G/NN;
% % Bͨ��
% EX1_B=EX1_B/NN;
% EY1_SP_B=EY1_SP_B/NN;
% EY1_CZ_B=EY1_CZ_B/NN;
% EY1_DJX_B=EY1_DJX_B/NN;
% for i=1:NN
%     %��һ�����ص��D��ˮƽ����ֱ���Խ���ʱ����ó���һ�����ص��D��ͬ��ͳһ��DX��ʾ
%     DX1_R=DX1_R+(I1(x1(i),y1(i))-EX1_R)^2;
%     DX1_G=DX1_G+(I2(x1(i),y1(i))-EX1_G)^2;
%     DX1_B=DX1_B+(I3(x1(i),y1(i))-EX1_B)^2;
%     %�ڶ������ص��D��ˮƽ����ֱ���Խ��ߵ�D�ֱ��ӦDY1_SP��DY1_CZ��DY1_DJX
%     %Rͨ��
%     DY1_SP_R=DY1_SP_R+(I1(x1(i),y1(i)+1)-EY1_SP_R)^2;
%     DY1_CZ_R=DY1_CZ_R+(I1(x1(i)+1,y1(i))-EY1_CZ_R)^2;
%     DY1_DJX_R=DY1_DJX_R+(I1(x1(i)+1,y1(i)+1)-EY1_DJX_R)^2;
%     %Gͨ��
%     DY1_SP_G=DY1_SP_G+(I2(x1(i),y1(i)+1)-EY1_SP_G)^2;
%     DY1_CZ_G=DY1_CZ_G+(I2(x1(i)+1,y1(i))-EY1_CZ_G)^2;
%     DY1_DJX_G=DY1_DJX_G+(I2(x1(i)+1,y1(i)+1)-EY1_DJX_G)^2;
%     %Bͨ��
%     DY1_SP_B=DY1_SP_B+(I3(x1(i),y1(i)+1)-EY1_SP_B)^2;
%     DY1_CZ_B=DY1_CZ_B+(I3(x1(i)+1,y1(i))-EY1_CZ_B)^2;
%     DY1_DJX_B=DY1_DJX_B+(I3(x1(i)+1,y1(i)+1)-EY1_DJX_B)^2;
%     %�����������ص���غ����ļ��㣬ˮƽ����ֱ���Խ���
%     %Rͨ��
%     COVXY1_SP_R=COVXY1_SP_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i),y1(i)+1)-EY1_SP_R);
%     COVXY1_CZ_R=COVXY1_CZ_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i)+1,y1(i))-EY1_CZ_R);
%     COVXY1_DJX_R=COVXY1_DJX_R+(I1(x1(i),y1(i))-EX1_R)*(I1(x1(i)+1,y1(i)+1)-EY1_DJX_R);
%     %Gͨ��
%     COVXY1_SP_G=COVXY1_SP_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i),y1(i)+1)-EY1_SP_G);
%     COVXY1_CZ_G=COVXY1_CZ_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i)+1,y1(i))-EY1_CZ_G);
%     COVXY1_DJX_G=COVXY1_DJX_G+(I2(x1(i),y1(i))-EX1_G)*(I2(x1(i)+1,y1(i)+1)-EY1_DJX_G);
%     %Bͨ��
%     COVXY1_SP_B=COVXY1_SP_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i),y1(i)+1)-EY1_SP_B);
%     COVXY1_CZ_B=COVXY1_CZ_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i)+1,y1(i))-EY1_CZ_B);
%     COVXY1_DJX_B=COVXY1_DJX_B+(I3(x1(i),y1(i))-EX1_B)*(I3(x1(i)+1,y1(i)+1)-EY1_DJX_B);
% end
% %ͳһ��ѭ����������ص����1000���ɼ����������
% %Rͨ��
% DX1_R=DX1_R/NN;
% DY1_SP_R=DY1_SP_R/NN;
% DY1_CZ_R=DY1_CZ_R/NN;
% DY1_DJX_R=DY1_DJX_R/NN;
% COVXY1_SP_R=COVXY1_SP_R/NN;
% COVXY1_CZ_R=COVXY1_CZ_R/NN;
% COVXY1_DJX_R=COVXY1_DJX_R/NN;
% %Gͨ��
% DX1_G=DX1_G/NN;
% DY1_SP_G=DY1_SP_G/NN;
% DY1_CZ_G=DY1_CZ_G/NN;
% DY1_DJX_G=DY1_DJX_G/NN;
% COVXY1_SP_G=COVXY1_SP_G/NN;
% COVXY1_CZ_G=COVXY1_CZ_G/NN;
% COVXY1_DJX_G=COVXY1_DJX_G/NN;
% %Bͨ��
% DX1_B=DX1_B/NN;
% DY1_SP_B=DY1_SP_B/NN;
% DY1_CZ_B=DY1_CZ_B/NN;
% DY1_DJX_B=DY1_DJX_B/NN;
% COVXY1_SP_B=COVXY1_SP_B/NN;
% COVXY1_CZ_B=COVXY1_CZ_B/NN;
% COVXY1_DJX_B=COVXY1_DJX_B/NN;
% %ˮƽ����ֱ���Խ��ߵ������
% %Rͨ��
% RXY1_SP_R=COVXY1_SP_R/sqrt(DX1_R*DY1_SP_R);
% RXY1_CZ_R=COVXY1_CZ_R/sqrt(DX1_R*DY1_CZ_R);
% RXY1_DJX_R=COVXY1_DJX_R/sqrt(DX1_R*DY1_DJX_R);
% %Gͨ��
% RXY1_SP_G=COVXY1_SP_G/sqrt(DX1_G*DY1_SP_G);
% RXY1_CZ_G=COVXY1_CZ_G/sqrt(DX1_G*DY1_CZ_G);
% RXY1_DJX_G=COVXY1_DJX_G/sqrt(DX1_G*DY1_DJX_G);
% %Bͨ��
% RXY1_SP_B=COVXY1_SP_B/sqrt(DX1_B*DY1_SP_B);
% RXY1_CZ_B=COVXY1_CZ_B/sqrt(DX1_B*DY1_CZ_B);
% RXY1_DJX_B=COVXY1_DJX_B/sqrt(DX1_B*DY1_DJX_B);




%% ���벿��
% load codebook_step4%�����뱾��ѹ������Ϊ2.
% step=4;%��������
x=240;%ͼ�������
y=240;%ͼ�������
xx=40;%����Ԫ������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
yy=240;%����Ԫ������
z=0;%ROI��ʼ����
w=0;%ROI��ʼ����
% q=0;%ROI��������
% p=0;%ROI��������

%bayer��ɫ�˲����и�ʽ
%  B  G
%  G  R
filter(:,:,3)=[1 0;0 0];%bayer��ɫ�˲�����b����
filter(:,:,2)=[0 1;1 0];%bayer��ɫ�˲�����g����
filter(:,:,1)=[0 0;0 1];%bayer��ɫ�˲�����r����
% A0(1,1,1) = 1;  
%����ͨGRB��ɫ��Ƭת��BAYER��ʽ��Ƭ
for i=1:x/2%������ÿ���˲�����Ϊ2*2,ͼ����x�У�������Ҫѭ��120��
    for j=1:y/2%������ѭ��160��
        A0(2*i-1:2*i,2*j-1:2*j,:)=A0(2*i-1:2*i,2*j-1:2*j,:).*filter;
    end
end

bayerimage0=A0;


temp=zeros(x,y,1);
temp=A0(:,:,1)+A0(:,:,2)+A0(:,:,3);
A0=temp;%A0���ת�����˵�bayer��Ƭ���ߴ���x*y*1
clear temp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A0=round(A0/2);%��Ӧ��NEAR=1;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% A0=round(A0/4);%��Ӧ��NEAR=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��bayerͼ���и�������������
temp1=zeros(1,y/2);
temp2=zeros(1,y/2);
for i=1:x%��ÿһ���ڵ�������������һ�£���ɫ����ߣ�������ɫ�ߵ�˳�����ұߡ��ߵ�˳�����ʹ��ͬ��ɫ��������ƽ��Щ��
    if mod(i,2)==1%�����������
        temp1=A0(i,1:2:y-1);%��ɫB
        temp2=A0(i,2:2:y);%��ɫG1
        A0(i,1:y/2)=temp2;%��G���з������
        A0(i,(y/2)+1:end)=temp1(end:-1:1);%��������ɫ���ұߡ�ע��˳�򵹹�������������ͼƬƽ����
    else
        temp1=A0(i,1:2:y-1);%��ɫG2
        temp2=A0(i,2:2:y);%��ɫR
        A0(i,1:y/2)=temp1;%��G���з������
        A0(i,(y/2)+1:end)=temp2(end:-1:1);%��������ɫ���ұߡ�ע��˳�򵹹�������������ͼƬƽ����
    end
end
clear temp1 temp2


for k=1:6 %��240*240��ͼ��ֳ�40*240��������Ϊ��������Ԫ
    k
    A=A0(1+40*(k-1):40*k,:);
    
%     for i=2:yy%�Ի�������ͼ��Ԫ��20*120����ɫ����ͼ������ˮƽ�˲�
%         A(:,i)=round((A(:,i-1)+A(:,i))/2);
%     end
% 
%     for i=2:xx%�Ի�������ͼ��Ԫ��20*120����ɫ����ͼ������ˮƽ�˲�
%         A(i,:)=round((A(i-1,:)+A(i,:))/2);
%     end

    [JPEGLS_coderoutput1,JPEGLS_coderoutput2, code_index]=JPEGLS_coder(A, code_index, ans_code);
    totaloutput=strcat(totaloutput,JPEGLS_coderoutput1,JPEGLS_coderoutput2);
end

save totaloutput_k_test totaloutput;
%% �������
TotalCompressionRatio = x*y*8/length(totaloutput);%����ѹ����
clear A JPEGLS_coderoutput1 JPEGLS_coderoutput2 n A1 Errorquant i j m filter A0_color step;

       
        