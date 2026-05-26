function [Geiv, CvecGeiv] = FRF_EIV(G, CvecG);
%
%		Calculates the input/output FRF and its covariance matrix from the reference signal 
%       to the input/output FRF and its covariance matrix.
%       (Note: Reference signal: nu x 1; input signal: nu x 1; output signal: ny x 1) 
%       
%
%	function [Geiv, CvecGeiv] = FRF_EIV(G, CvecG);
%
%	Output parameters
%
%
%       Geiv    =   estimated input/output frequency response matrix, size ny x nu x F
%
%       CvecGeiv   =   covariance matrix vec(G), size (ny*nu) x (ny*nu) x F
%
%	Input parameters
%
%       G       =   estimated frequency response matrix, size (ny + nu) x nu x F
%
%       CvecG   =   covariance matrix vec(G), size ((ny+nu)*nu) x ((ny+nu)*nu) x F
%
%
% Rik Pintelon, November 21, 2008
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialisation variables %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nz, nu, F] = size(G);
ny = nz-nu;                 % number of outputs

Geiv = zeros(ny, nu, F);
CvecGeiv = zeros(ny*nu, ny*nu, F);


%%%%%%%%%%%%%%%%%%%%
% Input-output FRF %
%%%%%%%%%%%%%%%%%%%%

for kk = 1:F
    
    % inverse FRF from reference to input
    Gru_inv = inv(squeeze(G(ny+1:end,:,kk)));
 
    % input-output FRF
    Geiv(:,:,kk) = G(1:ny,:,kk) * Gru_inv;
    
    % covariance matrix input-output FRF
    dummy = kron(Gru_inv.', [eye(ny), -squeeze(Geiv(:,:,kk))]);
    CvecGeiv(:,:,kk) = dummy * CvecG(:,:,kk) * dummy';
    
end % for kk
