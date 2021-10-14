%% �Ӻ��� ���Chen�ϳ�����ϵͳ
%����ode45���
%�ο���https://zhidao.baidu.com/question/1959859560446863460.html
function fy=chen_output(x0,y0,z0,h0,num)
% ΢�ַ������
opt = odeset('Mass',@mass);
y0=[x0;y0;z0;h0];
[~,y] = ode45(@ode,0:500/(num+3000):500,y0,opt);
fy=y;
    function f = ode(~,y)
        y1=y(1);
        y2=y(2);
        y3=y(3);
        y4=y(4);
        f = [35*(y2-y1)+y4;7*y1-y1*y3+12*y2;y1*y2-3*y3;y2*y3+0.2*y4];
    end
    function M = mass(~,~)
        M = [1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,1];
    end
end