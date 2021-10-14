%����6x40�Ĵ�С���ζ�ȡͼ��ĸ�������
%ͼ���СΪx*y,����ȡ48��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global bayerimage0 
% load codebook_step1%�����뱾
% step=1;%ѹ������Ϊ2
x=240;%ͼ�������
y=240;%ͼ�������
xx=40;%����Ԫ������
yy=240;%����Ԫ������
z=0;%ROI��ʼ����
w=0;%ROI��ʼ����
% q=0;%ROI��������
% p=0;%ROI��������
code_index = 1;
load ans_code;

t0=cputime;%��ʼ��ʱ


%%
for k=1:6
    k
    [Re_A,totaloutput, code_index]=JPEGLS_decoder(totaloutput, code_index, ans_code);
%     for i=xx:-1:2%�Բ�ɫ����ͼ���д�ֱ���˲�
%         Re_A(i,:)=2*Re_A(i,:)-Re_A(i-1,:);
%     end
%         
%     for i=yy:-1:2%�Բ�ɫ����ͼ����ˮƽ���˲�
%         Re_A(:,i)=2*Re_A(:,i)-Re_A(:,i-1);
%     end
    
    Re_A0(1+40*(k-1):40*k,:)=Re_A;%ͼ��Ľ���
end

time=cputime-t0%��ʱ����

clear  t0 time

        




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����к��bayerͼ�ظ���������BAYER��ʽͼ��
%Ԥ�����а�bayerͼ���и�������������
%���������
temp1=zeros(1,y/2);
temp2=zeros(1,y/2);
for i=1:x%��ÿһ���ڵ�������������һ�£���ɫ����ߣ�������ɫ�ߵ�˳�����ұߡ������������
    if mod(i,2)==1%�����������
        temp1=Re_A0(i,1:y/2);%��ɫG1
        temp2=Re_A0(i,(y/2)+1:end);%��ɫB
        Re_A0(i,1:2:y-1)=temp2(end:-1:1);%��B�ߵ�˳������������
        Re_A0(i,2:2:y)=temp1;%��G1����ż����
    else
        temp1=Re_A0(i,1:y/2);%��ɫG2
        temp2=Re_A0(i,(y/2)+1:end);%��ɫR
        Re_A0(i,1:2:y-1)=temp1;%��G2���з���������
        Re_A0(i,2:2:y)=temp2(end:-1:1);%��R����ż����
    end
end
save Re_A0_k_test Re_A0;
clear temp1 temp2

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����ͨbayer��Ƭת��������ɫ���׼RGB��ʽ
tempRe_A0=zeros(x,y,3);
for i=1:x
    for j=1:y%����
        if (mod(i,2)==1) && (mod(j,2)==1)
            tempRe_A0(i,j,3)=Re_A0(i,j);%B�����ŵ���3��
        else
            if (mod(i,2)==0) && (mod(j,2)==0)
                tempRe_A0(i,j,1)=Re_A0(i,j);%R�����ŵ���1��
            else
                tempRe_A0(i,j,2)=Re_A0(i,j);%G�����ŵ���2��
            end
        end
    end
end

Re_A0=tempRe_A0;
% figure;imhist(Re_A0(:,:,2));title('����ͼƬͨ��ֱ��ͼ');
% clear tempRe_A0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Re_A0=Re_A0*2;%��Ӧ��NEAR=1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Re_A0=Re_A0*4;%��Ӧ��NEAR=2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
subplot(2,2,3),subimage(uint8(Re_A0)),title('�ָ�BAYERͼ��Re_A0')


bayerimage1=Re_A0;%����PSNR�õĲ�����ʵ��ʹ��ʱ��ɾ��



%��BAYER��ʽ��Ƭ���в�ֵ���ָ���ΪRGB��ɫ��Ƭ
for i=2:2:x-2
    Re_A0(i,:,3)=(Re_A0(i-1,:,3)+Re_A0(i+1,:,3))/2;
end
Re_A0(x,:,3)=Re_A0(x-1,:,3);

for i=2:2:y-2
    Re_A0(:,i,3)=(Re_A0(:,i-1,3)+Re_A0(:,i+1,3))/2;
end
Re_A0(:,y,3)=Re_A0(:,y-1,3);       %��Re_A0��Ƭ��B������ֵ�ָ�


for i=3:2:x-1
    Re_A0(i,:,1)=(Re_A0(i-1,:,1)+Re_A0(i+1,:,1))/2;
end
Re_A0(1,:,1)=Re_A0(2,:,1);

for i=3:2:y-1
    Re_A0(:,i,1)=(Re_A0(:,i-1,1)+Re_A0(:,i+1,1))/2;
end
Re_A0(:,1,1)=Re_A0(:,2,1);           %��Re_A0��Ƭ��R������ֵ�ָ�

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
end %��Re_A0��Ƭ��G������ֵ�ָ�


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ͼ������PSNR
A0=imread('sample3.bmp');%����ͼ�񣬱�׼ͼ���СΪx*y~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
subplot(2,2,2),subimage(A0),title('ԭʼRGBͼ��A0')
Re_A0=uint8(Re_A0);%������н�ͼ������Ԫ�ظĳ�double���ȣ������������Ҫת����uint8ģʽ
subplot(2,2,4),subimage(Re_A0),title('�ָ�RGBͼ��Re_A0')

A0_1D=zeros(1,x*y*3);%ͼ��A0��һά���
count=1;
for k=1:3
    for i=1:x %i��ʾͼ����ĳ���ص�����
        for j=1:y %j��ʾͼ����ĳ���ص�����
            A0_1D(count)=bayerimage0(i,j,k);%��Errorquant������Ԫ��ת�Ƶ���Errorquant_1D��
            count=count+1;                %Errorquant_1D��һά����
        end
    end
end

Re_A0_1D=zeros(1,x*y*3);%�ָ�ͼ��Re_A0��һά���
count=1;
for k=1:3
    for i=1:x %i��ʾͼ����ĳ���ص�����
        for j=1:y %j��ʾͼ����ĳ���ص�����
            Re_A0_1D(count)=bayerimage1(i,j,k);%��Errorquant������Ԫ��ת�Ƶ���Errorquant_1D��
            count=count+1;                %Errorquant_1D��һά����
        end
    end
end
MSE=sum((A0_1D-Re_A0_1D).^2)/length(A0_1D);
PSNR=10*log10((2^8-1)^2/MSE)%��ֵ�����
subplot(2,2,1),subimage(uint8(bayerimage0)),title('ԭʼBAYERͼ��A0')
% clear A0_1D Re_A0_1D count i j k MSE Re_A n totaloutput A0 Re_A0 A0_color Re_A0_color filter m;


% ͼ����Ϣͳ��
I11=Re_A0(:,:,1);        %R
I22=Re_A0(:,:,2);        %G
I33=Re_A0(:,:,3);        %B
figure;imhist(I11);title('����ͼƬRͨ��ֱ��ͼ');
figure;imhist(I22);title('����ͼƬGͨ��ֱ��ͼ');
figure;imhist(I33);title('����ͼƬBͨ��ֱ��ͼ');


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
    XX_R_SP(i)=I11(x1(i),y1(i));
    YY_R_SP(i)=I11(x1(i)+1,y1(i));
    XX_G_SP(i)=I22(x1(i),y1(i));
    YY_G_SP(i)=I22(x1(i)+1,y1(i));
    XX_B_SP(i)=I33(x1(i),y1(i));
    YY_B_SP(i)=I33(x1(i)+1,y1(i));
    %��ֱ
    XX_R_CZ(i)=I11(x1(i),y1(i));
    YY_R_CZ(i)=I11(x1(i),y1(i)+1);
    XX_G_CZ(i)=I22(x1(i),y1(i));
    YY_G_CZ(i)=I22(x1(i),y1(i)+1);
    XX_B_CZ(i)=I33(x1(i),y1(i));
    YY_B_CZ(i)=I33(x1(i),y1(i)+1);
    %�Խ���
    XX_R_DJX(i)=I11(x1(i),y1(i));
    YY_R_DJX(i)=I11(x1(i)+1,y1(i)+1);
    XX_G_DJX(i)=I22(x1(i),y1(i));
    YY_G_DJX(i)=I22(x1(i)+1,y1(i)+1);
    XX_B_DJX(i)=I33(x1(i),y1(i));
    YY_B_DJX(i)=I33(x1(i)+1,y1(i)+1);
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
figure;scatter(XX_R_DJX,YY_R_DJX,18,'filled');xlabel('Rͨ����������ػҶ�ֵ');ylabel('��õ����ڶԽ��߷������ػҶ�ֵ');title('����ͼ��Rͨ���Խ�������Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_G_DJX,YY_G_DJX,18,'filled');xlabel('Gͨ����������ػҶ�ֵ');ylabel('��õ����ڶԽ��߷������ػҶ�ֵ');title('����ͼ��Gͨ���Խ�������Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
figure;scatter(XX_B_DJX,YY_B_DJX,18,'filled');xlabel('Bͨ����������ػҶ�ֵ');ylabel('��õ����ڶԽ��߷������ػҶ�ֵ');title('����ͼ��Bͨ���Խ�������Ԫ������Ե�ͼ');axis([0 255,0 255]);set(gca,'XTick',0:15:255);set(gca,'YTick',0:15:255);
% %Rͨ��


