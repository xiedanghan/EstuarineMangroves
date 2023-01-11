% MY GODness: To use 'prctile', the following product must be both licensed and installed:
% If you don?t have the Statistics Toolbox, this doesn't replicate the prctile results exactly, but it's close:
function a = pctl(v,p) 
if isempty(v)
    a = 0;
elseif numel(v) <= 2
    a = max(v);
else 
    a = interp1(linspace(0.5/size(v,1), 1-0.5/size(v,1), size(v,1))', sort(v), p*0.01, 'spline');
end