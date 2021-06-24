classdef Modes < handle
% This class creates the modes used for scale separation and/or order
% reduction. For now the 2D wavelet option works only on a grid of
% equal size in both dimensions.

    properties
        
        N; % state size
        
        V; % stores the modes        

        red_factor = 1; % reduction factor for order reduction
        
        % scale separation options
        scale_separation = 'wavelet'; % options: 'wavelet', 'pod'

        % Size of the wavelet blocks inside a wavelet transform matrix. For a
        % 2D wavelet the block size has an integer sqrt.
        blocksize = 8;

        dimension = '1D'; % selects a wavelet for a 1D field or a
                          % wavelet for a 2D field in column
                          % major ordering

        nun = 1; % number of independent unknowns a wavelet needs to
                 % act on
    end

    methods
        function self = Modes(type, pars)
        % constructor

            self.scale_separation = type;
            self.set_parameters(pars);

            if strcmp(self.scale_separation, 'wavelet')
                self.V = self.build_wavelet(self.blocksize,...
                                            self.dimension,...
                                            self.nun);
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
                bs  = self.blocksize;
                dim = self.dimension;
                nun = self.nun;
              case 2
                dim = self.dimension;
                nun = self.nun;
              case 3
                nun = self.nun;
            end

            Nw = round(self.N / bs); % number of wavelet blocks
            assert(Nw == (self.N / bs), ...
                   'bs should be a divisor of N');
            
            % build wavelet block
            if strcmp(dim, '1D')
                % 1D wavelet transform for a state of size bs
                W = self.haarmat(bs);            
                
            elseif strcmp(dim, '2D')
                assert( round(sqrt(bs)) == sqrt(bs), ...
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

            % create a reordering matrix with the block size
            P1 = speye(self.N);
            id = [];
            
            for i = 1:bs
                id = [id, (i:bs:self.N)];
            end
            P1(:,id) = P1(:,1:self.N);
            
            if strcmp(dim, '2D')
                % create a nested reordering matrix within the block
                Pn = speye(bs);
                id = [];
                
                for i = 1:sqrt(bs)
                    id = [id, (i:sqrt(bs):bs)];
                end
                Pn(:,id) = Pn(:,1:bs);
                
                % duplicate for all blocks
                Pn = kron(I, Pn);
                
                % adjust P1 with this nested reordering
                P1 = P1*Pn;
            end                

            % create a block permutation matrix
            if strcmp(dim, '2D')
                n  = sqrt(self.N / nun);
                m  = sqrt(self.N / nun);
                P2 = self.build_block_permutation(n, m, nun, sqrt(bs));
            else
                P2 = speye(self.N);
            end

            % complete wavelet operator
            V = P2'*H'*P1';
        end

        function [P] = build_block_permutation(self, n, m, nun, bs)
            dim = n*m*nun;
            assert(dim == self.N, 'inconsistent dimensions');
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
        %$#TODO
        end
    end
end