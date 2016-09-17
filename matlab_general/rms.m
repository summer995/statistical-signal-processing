function y = rms(x) %Root Mean Square
y=sqrt(sum(x.^2)./length(x));