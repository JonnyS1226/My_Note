        function [MErrval,totaloutput]=GolombDecoding(totaloutput,k, LIMIT,qbpp)

        val1 = 0;
        val2 = 0;
        val3 = LIMIT-qbpp-1;
        
        %����������ٸ�0����������Ϊval1,ΪMerrval/2^K����
        count=1;
        while totaloutput(count)~='1'
            val1=val1+1; 
            count=count+1;
        end
%         totaloutput(1:count-1)=[];%ȡ�����ݺ�ѹ������������ӦԪ��ɾ��~~~~~~~~~~~~~~~~~~~~~~~~ԭ�������ж���ǰ�벿�ֵ�һԪ���룬ֻȡ��0��û��ɾ��1
        totaloutput(1:count)=[];%ȡ�����ݺ�ѹ������������ӦԪ��ɾ��
        
        if(val1<val3)
            val2=val1*(2^k);  %val2����val1�Ŵ�2^k��
            %����k��bit��ΪMErravl/2^K���������ۼӵ�VAL2�Ϻ�VAL2��ΪMErravl
            %��λ����������Բο�����
            if k~=0 %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ԭ��û�����if�����ǻ����k����0�����
%                 temp=char();
                for i=1:k
                    temp(i)=totaloutput(i);
                end
                val2=val2+bin2dec(temp(1:k));
                totaloutput(1:k)=[];%ȡ�����ݺ�ѹ������������ӦԪ��ɾ��
%                 clear temp
            end   %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        else
            %��������Ϊqbpp��ֵΪMErrval-1
%             temp=char();
            for i=1:qbpp
                temp(i)=totaloutput(i);
            end
            val2=bin2dec(temp(1:qbpp));
            val2=val2+1;%+1�󣬾ͼ������MErrval
            totaloutput(1:qbpp)=[];%ȡ�����ݺ�ѹ������������ӦԪ��ɾ��
%             clear temp
        end
        MErrval=val2;
        