%Signal despread

function out = despread(data, code)
% ****************************************************************
% data: input data sequence
% code: Spreading code sequence used for despreading
% out: output data sequence after despreading
% ****************************************************************
switch nargin                         
case { 0 , 1 }
    error('Missing input parameters');
end

[hn,vn] = size(data);
[hc,vc] = size(code);                  

out    = zeros(hc,vn/vc);                  

for ii=1:hc
    xx=reshape(data(ii,:),vc,vn/vc);
    out(ii,:)= code(ii,:)*xx/vc;
end

%******************************** end of file ********************************
