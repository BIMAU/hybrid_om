classdef DataGen < handle
% Generates training data. Training data consists of a transient of a
% perfect model (truth) and imperfect model predictions. When the two
% models live on different grids, appropriate restriction and
% prolongation operators should be supplied. In that case we assume
% that the training data lives on the coarse grid.

    properties
        % models
        model_prf;  % perfect model
        model_imp;  % imperfect model
        N_prf; % size of the perfect model grid
        N_imp; % size of the imperfect model grid
        x_init_prf; % initial perfect model state

        % time stepping
        dt = 0.1; % time step
        T  = 10;  % end time
        Nt; % number of time steps

        R; % restriction operator between two grids
        P; % prolongation operator between two grids

        X;   % stores the transient. In the case of two grids this is the
             % transient restricted to the coarse grid. We discard the
             % original fine grid transient to save memory.

        Phi; % stores the imperfect predictions on the coarse grid

    end

    methods
        function self = DataGen(model_prf, model_imp)
            self.model_prf = model_prf;
            self.model_imp = model_imp;

            self.N_prf = self.model_prf.N();
            self.N_imp = self.model_imp.N();

            self.x_init_prf = zeros(self.N_prf, 1);
            self.x_init_prf(1) = 1;
        end

        function generate_prf_transient(self);
            % evolve full model for Nt steps
            time = tic;
            self.Nt = ceil(self.T / self.dt);

            self.X      = zeros(self.N_prf, self.Nt);
            self.X(:,1) = self.x_init_prf;

            fprintf('Generate time series... \n');
            avg_k = 0;
            for i = 2:self.Nt
                [self.X(:,i), k] = ...
                    self.model_prf.step(self.X(:,i-1), self.dt);
                avg_k = avg_k + k;
            end

            fprintf('Generate time series... done (%f)\n', toc(time));
            fprintf('Average # Newton iterations: (%f)\n', ...
                    avg_k / (self.Nt-1));
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

            self.Phi = zeros(self.N_imp, self.Nt);
            time = tic;
            fprintf('Generate imperfect predictions... \n');
            avg_k = 0;
            for i = 1:self.Nt
                [self.Phi(:,i), k] = self.model_imp.step(self.X(:,i), self.dt);
                avg_k = avg_k + k;
            end
            fprintf('Generate imperfect predictions... done (%f)\n', toc(time));
            fprintf('Average # Newton iterations: (%f)\n', avg_k / self.Nt);

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
    end
end