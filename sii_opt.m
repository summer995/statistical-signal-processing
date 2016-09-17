function [xh SII_old SII_new] = sii_opt(x, n, fs)
%   [xh SII_old SII_new] = sii_opt(x, n, fs)
%
%   inputs:
%       x           = isolated clean speech
%       n           = isolated noise
%       fs          = samplerate
%   outputs:
%       xh          = processed speech signal
%       SII_old     = SII score for unprocessed speech
%       SII_new     = SII score for processed speech

addpath('matlab_general');

x       = x(:);
n       = n(:);

sii_bl  = [100 200 300 400 510 630 770 920 1080 1270 1480 1720 2000 2320 2700 3150 3700 4400 5300 6400 7700; 200 300 400 510 630 770 920 1080 1270 1480 1720 2000 2320 2700 3150 3700 4400 5300 6400 7700 9500];
sii_cf  = exp(mean(log(sii_bl)));
sii_bi  = [0.0103 0.0261 0.0419 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0577 0.0460 0.0343 0.0226 0.0110].';

N       = round(fs*32/1000);
[H cf]  = gt_getfb(150, min(fs/2, 8500), fs, N*2, 64);%auditory filter bank 的相应函数，cf为中心频率
w       = interp1(sii_cf, sii_bi, cf, 'linear', 'extrap');%一维插值函数
w       = w./sum(w);
w         = max(w, 0);%w为eq5中的r，即计算sii的系数

X    	= gt_analysis(x, H, N);%eq1 中的 Xmi
E       = gt_analysis(n, H, N);%eq1 噪声的Emi

VAD     = 10*log10(mean(X.^2))>(max(10*log10(mean(X.^2)))-60);

sig_x   = sqrt(mean(X(:, VAD).^2, 2));%eq2中的sigma_X，信号的能量
sig_e   = sqrt(mean(E(:, VAD).^2, 2));%eq2中的sigma_E，噪声的能量

alpha   = repmat(getOptimalGain(sig_x, sig_e, w), [1 size(X, 2)]);

Xh      = X.*alpha;

xh  	= gt_synthesis(Xh, x, H, N);
%xh  	= gt_synthesis(Xh, x+randn(size(x))*std(x)/1000, H, N);
xh      = norm(x).*xh./norm(xh);

SII_old	= w*(max(min(20*log10(sig_x./sig_e), 15), -15)./30+.5);%论文提到的原来方法计算出的sii，eq4
SII_new	= w*(max(min(20*log10(alpha(:, 1).*sig_x./sig_e), 15), -15)./30+.5);%论文自己的方法计算的sii
%(max(min(20*log10(alpha(:, 1).*sig_x./sig_e), 15),-15)./30+.5)
%相当于文中的eq4中的di,di表示人对语音信号的理解程度，1表示全部理解，0表示全部不理解


% 	This function processes a clean speech signal 'x' in order to 
%  	improve its speech intelligibility when played back in presence of 
%  	the noise 'n'. The method optimizes the speech intelligibility 
%  	index and is described in:
%
%  	C.H.Taal, J.Jensen and A.Leijon, 'On Optimal Linear Filtering 
% 	of Speech for Near-End Listening Enhancement', Signal Processing 
%  	Letters, 2013, 20(3), 225-228.
%   C.H. Taal and J. Jensen, "SII-based Speech Preprocessing for 
%   Intelligibility Improvement in Noise", Proc.Interspeech, Lyon, France, 
%   2013.
%


