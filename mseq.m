
function [mout] = mseq(n, taps, inidata, num)

% ****************************************************************
% n: the order n of the m sequence
% taps: the connection location of the feedback register
% inidata: initial value sequence of the register
% num: the number of m-sequences output
% mout: output m sequence, if num>1, then each row is an m sequence
% ****************************************************************



mout = zeros(num,2^n-1);
fpos = zeros(n,1);

fpos(taps) = 1;

for ii=1:2^n-1
    
    mout(1,ii) = inidata(n);                       
    temp        = mod(inidata*fpos,2);             
    
    inidata(2:n) = inidata(1:n-1);                 
    inidata(1)     = temp;                          
    
end

if num > 1                                         
    for ii=2:num
        mout(ii,:) = shift(mout(ii-1,:),1);
    end
end
