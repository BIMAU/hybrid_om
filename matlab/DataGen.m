classdef DataGen < handle
% Generates training data. Training data consists of a transient of a
% perfect model (truth) and imperfect model predictions. When the two
% models live on different grids, appropriate restriction and
% prolongation operators are available. In that case we assume that
% the resulting training data set lives on the coarse grid. In
% addition this class generates the wavelet or pod modes that can be
% used for scale separation of the training data.

    properties
        % models
        model_prf;  % perfect model
        model_imp;  % imperfect model
        N_prf; % size of the perfect model grid
        N_imp; % size of the imperfect model grid
        x_init_prf; % initial perfect model state


        % time stepping
        dt_prf = 0.1; % time step perfect model
        dt_imp = 0.1; % time step imperfect model (should be integer multiple
                      % of dt_prf)

        stride = 1; % dt_imp = stride * dt_prf

        T = 10; % end time
        Nt_prf; % number of time steps of the perfect model
        Nt_imp; % number of time steps of the imperfect model

        trunc = 0; % truncation of initial transient phase

        R; % restriction operator between two grids
        P; % prolongation operator between two grids

        X;   % stores the transient. In the case of two grids this is the
             % transient restricted to the coarse grid. We discard the
             % original fine grid transient to save memory.

        Phi; % stores the imperfect predictions on the coarse grid

        V; % stores the modes used for scale separation

        % scale separation options
        scale_separation = 'wavelet'; % options: 'wavelet', 'pod'

        % Size of the wavelet blocks inside a wavelet transform matrix. For a
        % 2D wavelet the block size has an integer sqrt. #FIXME: this
        % does not generalize to non-square grid sizes.
        wavelet_blocksize = 8;

        wavelet_dimension = '1D'; % selects a wavelet for a 1D field or a
                                  % wavelet for a 2D field in column
                                  % major ordering

        wavelet_nun = 1; % number of independent unknowns the wavelet needs to
                         % act on
    end

    methods
        function self = DataGen(model_prf, model_imp)
            self.model_prf = model_prf;
            self.model_imp = model_imp;

            self.N_prf = self.model_prf.N();
            self.N_imp = self.model_imp.N();

            self.x_init_prf = zeros(self.N_prf, 1);
            self.x_init_prf(1) = 1;

            if self.N_prf ~= self.N_imp
                fprintf('Datagen: grid transfer operators are required.\n')
            end
        end

        function generate_prf_transient(self);
        % evolve full model for Nt steps
            time = tic;
            self.Nt_prf = ceil(self.T / self.dt_prf);
            self.X      = zeros(self.N_prf, self.Nt_prf);
            self.X(:,1) = self.x_init_prf;

            fprintf('Generate time series... \n');
            avg_k = 0;
            for i = 2:self.Nt_prf
                [self.X(:,i), k] = ...
                    self.model_prf.step(self.X(:,i-1), self.dt_prf);
                avg_k = avg_k + k;
            end

            fprintf('Generate time series... done (%f)\n', toc(time));
            fprintf('Average # Newton iterations: (%f)\n', ...
                    avg_k / (self.Nt_prf-1));

            fprintf('Truncating t = [0,%d]\n', self.trunc);
            trunc_steps = floor(self.trunc / self.dt_prf);
            self.X = self.X(:,trunc_steps+1:self.Nt_prf);
            self.Nt_prf = size(self.X, 2);
            self.T = self.T - self.trunc;
        end

        function generate_imp_predictions(self)
        % When the size of the perfect and imperfect models differ, check that
        % there is a suitable restriction from the perfect to the
        % imperfect model grid.

            if self.N_prf ~= self.N_imp
                assert(~isempty(self.R), 'specify restriction operator R');
                assert(self.N_imp == size(self.R,1), 'incorrect row dimension in R');
                assert(self.N_prf == size(self.R,2), 'incorrect column dimension in R');
                self.X = self.R*self.X; % restrict the transient to the coarse grid
            end

            self.stride = round(self.dt_imp / self.dt_prf);
            assert( self.stride * self.dt_prf - self.dt_imp < 1e-13 , ...
                    'dt_imp is not an integer multiple of dt_prf');

            % reduce the transient, keep columns according to <stride>
            self.X = self.X(:,1:self.stride:self.Nt_prf);
            self.Nt_imp = size(self.X, 2);

            self.Phi = zeros(self.N_imp, self.Nt_imp);
            time = tic;
            fprintf('Generate imperfect predictions... \n');
            avg_k = 0;
            for i = 1:self.Nt_imp
                [self.Phi(:,i), k] = self.model_imp.step(self.X(:,i), self.dt_imp);
                avg_k = avg_k + k;
            end
            fprintf('Generate imperfect predictions... done (%f)\n', toc(time));
            fprintf('Average # Newton iterations: (%f)\n', avg_k / self.Nt_imp);

        end

        function build_grid_transfers(self, boundary, type)
        % Computes grid transfers between a grid of size N_prf and another of
        % size N_prf / 2

        % boundary: empty or 'periodic'
        % type: '1D' or '2D'

        % R: weighted restriction operator
        % P: prolongation operator

            assert(mod(self.N_prf,2) == 0);

            Nc = self.N_prf / 2;
            ico = [];
            jco = [];
            co  = [];
            for j = 1:Nc
                ico = [ico, j, j, j];
                jco = [jco, [2*j-1, 2*j, 2*j+1]];
                co  = [co, (1/4), (1/2), (1/4)];
            end

            if strcmp(boundary, 'periodic')
                % fix periodicity
                jco(end) = 1;
            end

            self.R = sparse(ico, jco, co, Nc, self.N_prf);
            self.P = 2*self.R';

            if strcmp(type, '2D')
                self.R = kron(self.R,self.R);
                self.P = 4*self.R';
            end
        end

        function [V] = build_wavelet(self, bs, dim, nun)
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
                %#FIXME this does not generalize to non-square 2D grids
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
            for i = 1:bs
                id = [id, (i:bs:self.N_imp)];
            end
            P1(:,id) = P1(:,1:self.N_imp);

            % create a block permutation matrix
            if strcmp(dim, '2D')
                %#FIXME this does not generalize to non-square 2D grids
                n  = sqrt(self.N_imp / nun); %#FIXME
                m  = sqrt(self.N_imp / nun); %#FIXME
                P2 = self.build_block_permutation(n, m, nun, sqrt(bs));
            else
                P2 = speye(self.N_imp);
            end

            % complete wavelet operator
            V = P2'*H'*P1';
            self.V = V;
        end

        function [P] = build_block_permutation(self, n, m, nun, bs)
            dim = n*m*nun;
            assert(dim == self.N_imp, 'inconsistend dimensions');
            P   = sparse(dim,dim);
            k   = 0;
            %#FIXME this does not generalize to non-square 2D grids
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