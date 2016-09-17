function a = getOptimalGain(sig_x, sig_e, w)
%返回能量重新分配的系数ai
sig_x   = sig_x(:);
sig_e   = sig_e(:);
w       = w(:);

msk_old = false(size(sig_x));

t1      = sig_e.*sqrt(w)./sig_x.^2;
t2      = sig_e.^2./sig_x.^2;
nu      = (sum(sqrt(w).*sig_e)./(sum(sig_x.^2)+sum(sig_e.^2))).^2;

a       = sqrt(t1/sqrt(nu)-t2);
msk     = ~(a.^2>0);

while ~isequal(msk, msk_old)%msk的大小等于ai的个数，ai不等于零则msk中对应位置为0，msk_old和msk相等说明ai的各项值也不在发生变化，即迭代结束
    nu      = (sum(sqrt(w(~msk)).*sig_e(~msk))./(sum(sig_x.^2)+sum(sig_e(~msk).^2))).^2;
    a       = sqrt(t1/sqrt(nu)-t2);
    msk_old = msk;
    msk     = ~(a.^2>0); 
end

a(msk)  = 0;