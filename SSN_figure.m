addpath(genpath(pwd));
%% process speech
clear all

[x fs]  	= wavread('SA1.wav');
x       	= x(:);

snr = -5:-1:-30;
old = zeros(length(snr));
new = zeros(length(snr));
for i=1:length(snr)
    y           = genSSN(x, snr(i)); % add some speech-shaped noise
    n           = y-x;
    [xn old(i) new(i)]  = sii_opt(x, n, fs);
end
plot(snr,old,snr,new);
legend('unprocessed SII','processed SII');
title('SSN(speech shape noise)');
