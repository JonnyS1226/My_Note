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
totaloutput='';%����ͼ������
A0=double(imread('sample6.bmp'));%����ͼ�񣬱�׼ͼ���СΪx*y~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% load codebook_step4%�����뱾��ѹ������Ϊ2��������˵ҽ��Ҫ��ͼƬ�������������Ծ����ܵĲ�Ҫ����ͼ������
% step=4;%��������
x=240;%ͼ�������
y=240;%ͼ�������
xx=40;%����Ԫ������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
yy=240;%����Ԫ������
z=0;%ROI��ʼ����
w=0;%ROI��ʼ����
q=0;%ROI��������
p=0;%ROI��������

%bayer��ɫ�˲����и�ʽ
%  B  G
%  G  R
filter(:,:,3)=[1 0;0 0];%bayer��ɫ�˲�����b����
filter(:,:,2)=[0 1;1 0];%bayer��ɫ�˲�����g����
filter(:,:,1)=[0 0;0 1];%bayer��ɫ�˲�����r����

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

A=A0; 
for i=2:yy%�Ի�������ͼ��Ԫ��20*120����ɫ����ͼ������ˮƽ�˲�
    A(:,i)=round((A(:,i-1)+A(:,i))/2);
end

for i=2:xx%�Ի�������ͼ��Ԫ��20*120����ɫ����ͼ������ˮƽ�˲�
    A(i,:)=round((A(i-1,:)+A(i,:))/2);
end

for i=1:6 %��240*240��ͼ��ֳ�40*240��������Ϊ��������Ԫ
    i
    [JPEGLS_coderoutput1,JPEGLS_coderoutput2]=JPEGLS_coder(A(1+40*(i-1):40*i,:));
    totaloutput=strcat(totaloutput,JPEGLS_coderoutput1,JPEGLS_coderoutput2);
end

TotalCompressionRatio=x*y*8/length(totaloutput)%����ѹ����
clear A JPEGLS_coderoutput1 JPEGLS_coderoutput2 n A1 Errorquant i j m filter A0_color step;

       
save temp.mat totaloutput TotalCompressionRatio
clear
load temp.mat

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
q=0;%ROI��������
p=0;%ROI��������


t0=cputime;%��ʼ��ʱ
for i=1:6
    i
    [Re_A(1+40*(i-1):40*i,:),totaloutput]=JPEGLS_decoder(totaloutput);
end
       
for i=xx:-1:2%�Բ�ɫ����ͼ���д�ֱ���˲�
    Re_A(i,:)=2*Re_A(i,:)-Re_A(i-1,:);
end
        
for i=yy:-1:2%�Բ�ɫ����ͼ����ˮƽ���˲�
    Re_A(:,i)=2*Re_A(:,i)-Re_A(:,i-1);
end
        
Re_A0=Re_A;%ͼ��Ľ���
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
clear temp1 temp2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����ͨbayer��Ƭת��������ɫ���׼RGB��ʽ
tempRe_A0=zeros(x,y,3);
for i=1:x
    for j=1:y%����
        if (mod(i,2)==1) & (mod(j,2)==1)
            tempRe_A0(i,j,3)=Re_A0(i,j);%B�����ŵ���3��
        else
            if (mod(i,2)==0) & (mod(j,2)==0)
                tempRe_A0(i,j,1)=Re_A0(i,j);%R�����ŵ���1��
            else
                tempRe_A0(i,j,2)=Re_A0(i,j);%G�����ŵ���2��
            end
        end
    end
end
Re_A0=tempRe_A0;
clear tempRe_A0

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
A0=double(imread('sample6.bmp'));%����ͼ�񣬱�׼ͼ���СΪx*y~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
subplot(2,2,2),subimage(uint8(A0)),title('ԭʼRGBͼ��A0')
Re_A0=uint8(Re_A0);%��������н�ͼ������Ԫ�ظĳ�double���ȣ������������Ҫת����uint8ģʽ
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
% clear A0_1D Re_A0_1D count i j k MSE Re_A n totaloutput A0 Re_A0 A0_color
% Re_A0_color filter m;
        