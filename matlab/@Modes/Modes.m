classdef Modes < handle
% This class creates the modes used for scale separation and/or order
% reduction. For now the 2D wavelet option works only on a grid of
% equal size in both dimensions.

    properties

        N; % state size

        V; % stores the modes

        Vinv; % inverse of the modes

        Vc; % stores the complement modes

        Vcinv; % inverse of the complement modes


        red_factor = 1; % reduction factor for order reduction

        % scale separation options: 'wavelet', 'pod', 'local_pod', 'dmd'
        scale_separation = 'wavelet';

        % Size of the wavelet blocks inside a wavelet transform matrix. For a
        % 2D wavelet the block size has an integer sqrt.
        blocksize = 16;

        dimension = '1D'; % selects a wavelet for a 1D field or a
                          % wavelet for a 2D field in column
                          % major ordering

        nun = 1; % number of independent unknowns a wavelet needs to
                 % act on

        % flag that controls the ordering in build_block_permutation
        separate_unknowns = false;
    end

    methods
        function self = Modes(type, pars, data, train_range)
        % constructor

            self.scale_separation = type;
            self.set_parameters(pars);

            if strcmp(self.scale_separation, 'wavelet')
                [self.V, self.Vinv, self.Vc, self.Vcinv] = ...
                    self.build_wavelet(data, train_range);

            elseif strcmp(self.scale_separation, 'pod')
                [self.V, self.Vinv, self.Vc, self.Vcinv] = ...
                    self.build_pod(data, train_range);

            elseif strcmp(self.scale_separation, 'local_pod')
                [self.V, self.Vinv, self.Vc, self.Vcinv] = ...
                    self.build_local_pod(data, train_range);

            elseif strcmp(self.scale_separation, 'wav+pod')
                [self.V, self.Vinv, self.Vc, self.Vcinv] = ...
                    self.build_wavpod(data, train_range);

            elseif strcmp(self.scale_separation, 'dmd')
                [self.V, self.Vinv, self.Vc, self.Vcinv] = ...
                    self.build_dmd(data, train_range);

            elseif strcmp(self.scale_separation, 'none')
                % return identity
                self.V = speye(self.N, self.N);
                self.Vinv = speye(self.N, self.N);
                self.Vc = 0;
                self.Vcinv = 0;
            else
                error('unexpected input')
            end
        end

        function [V, Vinv, Vc, Vcinv] = build_wavpod(self, data, train_range)

        % build wavelet
            [H, Hinv, Hc, Hcinv] = ...
                self.build_wavelet(data, train_range);

            % build POD on (reduced) wavelet coordinates
            Xr = Hinv*data.X(:,train_range);
            [U,~,~] = svd(Xr, 'econ');

            V = H*U;
            Vinv = V';

            Vc = Hc;
            Vcinv = Hcinv;
        end

        function [U, Uinv, Uc, Ucinv] = build_pod(self, data, train_range)
            [U,S,V] = svd(data.X(:,train_range), 'econ');

            % reduces rows so we obtain the transpose/inverse
            [Uinv, Ucinv] = self.reduce(U');
            U = Uinv';
            Uc = Ucinv';

            maxdiff = max(max(abs(speye(size(U,2))-Uinv*U)));
            assert(maxdiff < 1e-14, "POD U not orthogonal");

            if ~isempty(Uc)
                maxdiff = max(max(abs(speye(size(Uc,2))-Ucinv*Uc)));
                assert(maxdiff < 1e-14, "POD U not orthogonal");
            else
                Uc = 0;
                Ucinv = 0;
            end
        end

        function [V, Vinv, Vc, Vcinv] = build_local_pod(self, data, train_range)
            bs = self.blocksize;
            if strcmp(self.dimension, '2D')
                n = sqrt(self.N / self.nun);
                m = sqrt(self.N / self.nun);
                P = self.build_block_permutation(n, m, self.nun, sqrt(bs));
            else
                P = speye(self.N);
            end

            % increasing the blocksize.
            % bs = 2*bs;

            nBlocks = self.N / bs;
            assert(round(nBlocks) == nBlocks, ...
                   "chosen block size is not a divisor of N");

            rf = self.red_factor;
            assert(rf*self.N == round(rf*self.N), ...
                   "reduction factor gives non-integers");

            % reduced block size
            bsr = rf*bs;
            bsc = bs - bsr;
            assert(bsr == round(bsr), ...
                   "reduction factor gives non-integers");

            U = sparse(self.N, rf*self.N);
            Uc = sparse(self.N, (1-rf)*self.N);
            for i = 1:nBlocks
                range_i = (i-1)*bs+1:i*bs;
                range_j = (i-1)*bsr+1:i*bsr;
                range_jc = (i-1)*bsc+1:i*bsc;

                [Ui,~,~] = svd(P(range_i,:)*data.X(:,train_range), 'econ');
                [Ui, Uic] = self.reduce(Ui');
                U(range_i, range_j) = Ui';
                if ~isempty(Uic)
                    Uc(range_i, range_jc) = Uic';
                end
            end

            V = P'*U;
            Vinv = V';
            if ~isempty(Uc)
                Vc = P'*Uc;
                Vcinv = Vc';
            else
                Vc = 0;
                Vcinv = 0;
            end
        end

        function [] = set_parameters(self, pars)
        % overwrite class params with params in pars struct
            assert(isstruct(pars));
            names = fieldnames(pars);
            for k = 1:numel(names)
                self.(names{k}) = pars.(names{k});
            end
            % check bounds on red_factor
            assert(self.red_factor <= 1, "Invalid reduction factor");
            assert(self.red_factor > 0, "Invalid reduction factor");
        end

        function [V, Vinv, Vc, Vcinv] = build_wavelet(self, data, train_range)
        % Build a wavelet matrix to represent a state of size N_imp in wavelet
        % coordinates: x = H*xc, with state x and coordinates xc. The
        % wavelet is ordered form large to small scales and is applied
        % to subdomains of size <bs> in 1D and sqrt<bs> x sqrt<bs> in
        % 2D.

        % dim: dimension, options:  '1D' or '2D'
        % bs:  block size. In 2D bs should have an integer sqrt

            bs  = self.blocksize;
            dim = self.dimension;
            nun = self.nun;

            Nw = round(self.N / bs); % number of wavelet blocks
            assert(Nw == (self.N / bs), ...
                   'bs should be a divisor of N');

            % build wavelet block
            if strcmp(dim, '1D')
                % 1D wavelet transform for a state of size bs
                W = self.haarmat(bs);
                [W, Wc] = self.reduce(W);

            elseif strcmp(dim, '2D')
                assert( round(sqrt(bs)) == sqrt(bs), ...
                        'in 2D bs should have an integer sqrt');
                W = self.haarmat(sqrt(bs));
                W = kron(W,W);

                % reorder rows, order in increasing detail
                id = reshape(1:bs, sqrt(bs), sqrt(bs))';
                id = id(:);
                W = W(id,:);

                % reduce
                [W, Wc] = self.reduce(W);
            else
                error('invalid dim option')
            end

            % create block diagonal wavelet matrix
            I = speye(Nw);
            H = kron(I, W);
            Hc = kron(I, Wc);

            % create a block permutation matrix
            if strcmp(dim, '2D')
                n = sqrt(self.N / nun);
                m = sqrt(self.N / nun);
                P = self.build_block_permutation(n, m, nun, sqrt(bs));
            else
                P = speye(self.N);
            end

            % complete wavelet operator
            V = P'*H';
            Vinv = V';

            % check that all modes are orthogonal
            maxdiff = max(max(abs(speye(size(V,2))-Vinv*V)));
            assert(maxdiff < 1e-14, "Wavelet modes V not orthogonal");

            % create complement
            if ~isempty(Hc)
                Vc = P'*Hc';
                Vcinv = Vc';
                maxdiff = max(max(abs(speye(size(Vc,2))-Vcinv*Vc)));
                assert(maxdiff < 1e-14, "Wavelet modes Vc not orthogonal");
                % mutual orthogonality
                mutorth = max(max(abs(Vcinv*V)));
                assert(mutorth < 1e-14, "Wavelet modes Vc not orthogonal");
            else
                Vc = 0;
                Vcinv = 0;
            end
        end

        function [P] = build_block_permutation(self, n, m, nun, bs)

            dim = n*m*nun;
            assert(dim == self.N, 'inconsistent dimensions');
            P   = sparse(dim,dim);
            k   = 0;

            if ~self.separate_unknowns
                % make smaller blocks
                bs = bs / nun;
            end

            for posj = 0:bs:n-bs
                rangej = posj+1:posj+bs;
                for posi = 0:bs:m-bs
                    rangei = posi+1:posi+bs;
                    if self.separate_unknowns
                        % separate unknowns, xx as outer iteration
                        for xx = 1:nun
                            for j = rangej
                                for i = rangei
                                    k = k + 1;
                                    col = nun*(n*(j-1)+(i-1))+xx;
                                    P(k,col) = 1;
                                end
                            end
                        end
                    else % keep unknowns together, xx as inner iteration
                        for j = rangej
                            for i = rangei
                                for xx = 1:nun
                                    k = k + 1;
                                    col = nun*(n*(j-1)+(i-1))+xx;
                                    P(k,col) = 1;
                                end
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

        function [Phr, Phrinv, Phc, Phcinv] = build_dmd(self, data, train_range)
            X = data.X(:,train_range(1):train_range(end)-1);
            Xp = data.X(:,train_range(2):train_range(end));
            [U,S,V] = svd(X, 'econ');

            r = round(self.red_factor*size(U,2));

            Ur = U(:,1:r); Sr = S(1:r,1:r); Vr = V(:,1:r);
            invSr = sparse(diag(1./diag(Sr)));
            Ar = Ur'*Xp*Vr*invSr;
            [Wr,Dr] = eig(Ar);
            Phr = real(Ur*Wr(:,1:2:end));
            Phrinv = pinv(Phr);

            % create complement
            if self.red_factor < 1
                Uc = U(:,r+1:end); Sc = S(r+1:end,r+1:end); Vc = V(:,r+1:end);
                invSc = sparse(diag(1./diag(Sc)));
                Ac = Uc'*Xp*Vc*invSc;
                [Wc,Dc] = eig(Ac);
                Phc = real(Uc*Wc(:,1:2:end));
                Phcinv = pinv(Phc);
            else
                Phc = 0;
                Phcinv = 0;
            end
        end



        function [Vout, Vcout] = reduce(self, Vin)
        % reduce the rows of the input matrix Vin with red_factor
        % return also the complement Vc
            rf = self.red_factor;
            if rf == 1
                Vout = Vin;
                Vcout = [];
            else
                nr = round(rf * size(Vin, 1));
                Vout = Vin(1:nr, :);
                Vcout = Vin(nr+1:end, :);
            end
        end
    end
end