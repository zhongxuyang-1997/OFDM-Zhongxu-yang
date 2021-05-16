% Spreading function
function [out] = spread(data, code)

% ****************************************************************
% data: input data sequence
% code: Spreading code sequence
% out: output data sequence after spreading
% ****************************************************************

switch nargin
case { 0 , 1 }                                  
    error('Missing input parameters');
end

[hn,vn] = size(data);
[hc,vc] = size(code);

if hn > hc                                      
    error('Lack of spreading code sequence');
end

out = zeros(hn,vn*vc);

for ii=1:hn
    out(ii,:) = reshape(code(ii,:).'*data(ii,:),1,vn*vc);
end

%******************************** end of file ********************************
