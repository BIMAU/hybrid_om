classdef Modes < handle
% This class creates the modes used for scale separation and/or order
% reduction. For now the 2D wavelet option works only on a grid of
% equal size in both dimensions.

    properties


        V; % stores the modes

        % scale separation options
        scale_separation = 'wavelet'; % options: 'wavelet', 'pod'

        % Size of the wavelet blocks inside a wavelet transform matrix. For a
        % 2D wavelet the block size has an integer sqrt.
        wavelet_blocksize = 8;

        wavelet_dimension = '1D'; % selects a wavelet for a 1D field or a
                                  % wavelet for a 2D field in column
                                  % major ordering

        wavelet_nun = 1; % number of independent unknowns the wavelet needs to
                         % act on

    end

    methods
        function self = Modes(type, pars)
        % constructor
            switch nargin
              case 1
                self.scale_separation = type;
              case 2
                self.scale_separation = type;
                self.set_parameters(pars);
            end

            if strcmp(self.scale_separation, 'wavelet')
                self.V = self.build_wavelet(self.wavelet_blocksize,...
                                            self.wavelet_dimensions,...
                                            self.wavelet_nun);
            elseif strcmp(self.scale_separation, 'pod')
                error('not implemented (yet)')
            else
                error('unexpected input')
            end
        end

        function [] = set_parameters(self, pars)
        % overwrite class params with params in pars struct
            assert(isstruct(pars));
            names = fieldnames(pars);
            for k = 1:numel(names)
                self.(names{k}) = pars.(names{k});
            end
        end

        function [V,H,P1,P2] = build_wavelet(self, bs, dim, nun)
        % Build a wavelet matrix to represent a state of size N_imp in wavelet
        % coordinates: x = H*xc, with state x and coordinates xc. The
        % wavelet is ordered form large to small scales and is applied
        % to subdomains of size <bs> in 1D and sqrt<bs> x sqrt<bs> in
        % 2D.

        % dim: dimension, options:  '1D' or '2D'
        % bs:  block size. In 2D bs should have an integer sqrt

            switch nargin
              case 1
                bs  = self.wavelet_blocksize;
                dim = self.wavelet_dimension;
                nun = self.wavelet_nun;
              case 2
                dim = self.wavelet_dimension;
                nun = self.wavelet_nun;
              case 3
                nun = self.wavelet_nun;
            end

            Nw = round(self.N_imp / bs); % number of wavelet blocks
            assert(Nw == (self.N_imp / bs), ...
                   'bs should be a divisor of N_imp');

            % build wavelet block
            if strcmp(dim, '1D')
                % 1D wavelet transform for a state of size bs
                W = self.haarmat(bs);

            elseif strcmp(dim, '2D')
                assert( round(sqrt(bs)) == sqrt(bs) , ...
                        'in 2D bs should have an integer sqrt');
                W = self.haarmat(sqrt(bs));

                % 2D wavelet transform for a field of size sqrt(bs) x sqrt(bs) in
                % column major ordering (:)
                W = kron(W,W);
            else
                error('invalid dim option')
            end

            % create block diagonal wavelet matrix
            I  = speye(Nw);
            H  = kron(I, W);

            % create a reordering matrix
            P1  = speye(self.N_imp);
            id = [];
            for i = 1:sqrt(bs)
                id = [id, (i:sqrt(bs):self.N_imp)];
            end
            P1(:,id) = P1(:,1:self.N_imp);

            % create a block permutation matrix
            if strcmp(dim, '2D')
                n  = sqrt(self.N_imp / nun);
                m  = sqrt(self.N_imp / nun);
                P2 = self.build_block_permutation(n, m, nun, sqrt(bs));
            else
                P2 = speye(self.N_imp);
            end

            % complete wavelet operator
            V = P2'*H'*P1';
        end

        function [P] = build_block_permutation(self, n, m, nun, bs)
            dim = n*m*nun;
            assert(dim == self.N_imp, 'inconsistend dimensions');
            P   = sparse(dim,dim);
            k   = 0;
            for posj = 0:bs:n-bs
                rangej = posj+1:posj+bs;
                for posi = 0:bs:m-bs
                    rangei = posi+1:posi+bs;
                    for xx = 1:nun
                        for j = rangej
                            for i = rangei
                                k = k + 1;
                                col = nun*(n*(j-1)+(i-1))+xx;
                                P(k,col) = 1;
                            end
                        end
                    end
                end
            end
            P = sparse(P);
        end

        function [W] = haarmat(self, p)
        % builds a single orthogonal Haar wavelet block of size p x p

            if p == 1
                W = 1;
                return
            end

            assert( round(log2(p)) == log2(p) , ...
                    'wavelet block size should be a power of 2');

            W   = 1/sqrt(2)*[1 1; 1 -1];
            dim = 2;
            while dim < p
                W = 1/sqrt(2)*[kron(W,[1 1]); kron(eye(dim),[1 -1])];
                dim = size(W,1);
            end
            W = sparse(W);
        end

        function build_pod(self)
        end
    end
end