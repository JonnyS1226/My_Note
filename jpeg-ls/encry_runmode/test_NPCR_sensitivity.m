%% 测试npcr
load Re_A0_k;
test_ReA0 = load('Re_A0_k_test.mat').Re_A0;

cnt = 0;
for i = 1 : 240
    for j = 1 : 240
        if (test_ReA0(i, j) == Re_A0(i, j)) 
            cnt = cnt + 1;
        end
    end
end
NPCR = 1 - cnt / (240 * 240);






%% 测试密钥敏感性
load totaloutput_k;
test_total = load('totaloutput_k_test.mat').totaloutput;

cnt2 = 0;
for i = 1 : min(length(totaloutput), length(test_total))
    if (totaloutput(i) ~= test_total(i)) 
        cnt2 = cnt2 + 1;
    end
end
bn = (max(length(totaloutput), length(test_total)) - min(length(totaloutput), length(test_total)) + cnt2) / max(length(totaloutput), length(test_total));