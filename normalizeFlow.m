% -------------------------------------------------------------------------
% The function normalizes flow for usage in tracking of body parts.
% -------------------------------------------------------------------------
function [u,v] = normalizeFlow(flow, varargin)

UNKNOWN_FLOW_THRESH = 1e9;
UNKNOWN_FLOW = 1e10;            % 

[height,widht,nBands] = size(flow);

if nBands ~= 2
    error('flowToColor: image must have two bands');    
end;    

u = flow(:,:,1);
v = flow(:,:,2);

maxu = -999;
maxv = -999;

minu = 999;
minv = 999;
maxrad = -1;

% fix unknown flow
idxUnknown = (abs(u)> UNKNOWN_FLOW_THRESH) | (abs(v)> UNKNOWN_FLOW_THRESH) ;
u(idxUnknown) = 0;
v(idxUnknown) = 0;

maxu = max(maxu, max(u(:)));
minu = min(minu, min(u(:)));

maxv = max(maxv, max(v(:)));
minv = min(minv, min(v(:)));

rad = sqrt(u.^2+v.^2);
maxrad = max(maxrad, max(rad(:)));

% fprintf('max flow: %.4f flow range: u = %.3f .. %.3f; v = %.3f .. %.3f\n', maxrad, minu, maxu, minv, maxv);

if isempty(varargin) ==0
    maxFlow = varargin{1};
    if maxFlow > 0
        maxrad = maxFlow;
    end;       
end;

u = u/(maxrad+eps).*rad;
v = v/(maxrad+eps).*rad;

