classdef DataGen < handle
% Generates training data. Training data consists of a transient of a
% perfect model (truth) and imperfect model predictions. When the two
% models live on different grids, appropriate restriction and
% prolongation operators are computed. In that case we assume that the
% resulting training data set lives on the coarse grid.

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

        dimension = '1D'; % can be '1D' or '2D'

        % save the data to out_file in path
        out_file;
        out_file_path;

        base_dir = '~/Projects/hybrid_om';

        % overwrite the data in out_file if true
        overwrite = false;

        % output during transient and predictions
        verbosity = 500;

        % allow this class to perform syscalls
        allow_syscall = true;
    end

    methods
        function self = DataGen(model_prf, model_imp, syscalls)
            assert(strcmp(model_prf.name, model_imp.name));

            self.model_prf = model_prf;
            self.model_imp = model_imp;

            self.N_prf = self.model_prf.N;
            self.N_imp = self.model_imp.N;

            self.x_init_prf = self.model_prf.x_init;

            if self.N_prf ~= self.N_imp
                fprintf('Grid transfer operators are required.\n')
            end

            % create path
            self.out_file_path = sprintf([self.base_dir, '/data/%s/%d_%d/'], ...
                                         self.model_prf.name, ...
                                         self.N_prf, self.N_imp);

            syscall = sprintf('mkdir -p %s', self.out_file_path);

            if self.allow_syscall
                system(syscall);
            end
        end

        function generate_prf_transient(self);
        % evolve full model for Nt steps

            out_file = [self.out_file_path, ...
                        sprintf('transient_T=%d_dt=%1.3f_param=%1.1e.mat', ...
                                self.T - self.trunc, self.dt_prf, ...
                                self.model_prf.control_param())];

            if exist(out_file, 'file') && ~self.overwrite
                fprintf('Obtain time series from file: \n %s \n', out_file);
                d = load(out_file);
                self.X = d.X;
                self.Nt_prf = d.Nt_prf;
                assert(d.T == self.T - self.trunc);
                self.T = d.T;
                fprintf('Obtained time series with %d samples.\n', self.Nt_prf);
            else
                fprintf('Not existing: %s\n', out_file);
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

                    if mod(i, self.verbosity) == 0
                        fprintf(' step %4d/%4d, Newton iterations: %d\n',...
                                i, self.Nt_prf, k);
                    end
                end

                fprintf('Generate time series... done (%f)\n', toc(time));
                fprintf('Average # Newton iterations: (%f)\n', ...
                        avg_k / (self.Nt_prf-1));

                fprintf('Truncating t = [0,%d]\n', self.trunc);
                trunc_steps = floor(self.trunc / self.dt_prf);
                self.X = self.X(:,trunc_steps+1:self.Nt_prf);
                self.Nt_prf = size(self.X, 2);
                self.T = self.T - self.trunc;

                fprintf('Saving time series to: \n %s \n', out_file);
                pairs = {{'X', self.X}, ...
                         {'Nt_prf', self.Nt_prf}, ...
                         {'T', self.T}};
                Utils.save_pairs(out_file, pairs);
                fprintf('Created time series with %d samples.\n', self.Nt_prf);
            end
        end

        function generate_imp_predictions(self)
        % When the size of the perfect and imperfect models differ, check that
        % there is a suitable restriction from the perfect to the
        % imperfect model grid.

            if self.N_prf ~= self.N_imp
                assert(~isempty(self.R), 'specify restriction operator R');
                assert(self.N_imp == size(self.R,1), 'incorrect row dimension in R');
                assert(self.N_prf == size(self.R,2), 'incorrect column dimension in R');
                fprintf('Grid transfer operators are available.\n')
                self.X = self.R*self.X; % restrict the transient to the coarse grid
            end

            self.stride = round(self.dt_imp / self.dt_prf);
            assert( self.stride * self.dt_prf - self.dt_imp < 1e-13 , ...
                    'dt_imp is not an integer multiple of dt_prf');

            if self.stride > 1
                fprintf('skipping every %d steps\n', self.stride)
                fprintf('   perfect model time step: %1.3f\n', self.dt_prf)
                fprintf(' imperfect model time step: %1.3f\n', self.dt_imp)
            end
            % reduce the transient, keep columns according to <stride>
            self.X = self.X(:,1:self.stride:self.Nt_prf);
            self.Nt_imp = size(self.X, 2);

            out_file = [self.out_file_path, ...
                        sprintf(['predictions_T=%d_dt=%1.3f_', ...
                                'stride=%d_Nt=%d_param=%1.2e.mat'], ...
                                self.T, self.dt_imp, self.stride, ...
                                self.Nt_imp, self.model_imp.control_param())];

            if exist(out_file, 'file') && ~self.overwrite
                fprintf('Obtain predictions from file: \n %s \n', out_file);
                d = load(out_file);
                self.Phi = d.Phi;
                fprintf('Obtained predictions: %d samples.\n', self.Nt_imp);
            else
                fprintf('Not existing: %s\n', out_file);
                self.Phi = zeros(self.N_imp, self.Nt_imp);
                time = tic;
                fprintf('Generate imperfect predictions... \n');
                avg_k = 0;

                for i = 1:self.Nt_imp
                    [self.Phi(:,i), k] = self.model_imp.step(self.X(:,i), self.dt_imp);
                    avg_k = avg_k + k;
                    if mod(i, self.verbosity) == 0
                        fprintf(' step %4d/%4d, Newton iterations: %d\n',...
                                i, self.Nt_imp, k);
                    end

                end

                fprintf('Generate imperfect predictions... done (%f)\n', toc(time));
                fprintf('Average # Newton iterations: (%f)\n', avg_k / self.Nt_imp);
                fprintf('Saving predictions to: \n %s \n', out_file);
                Utils.save_pairs(out_file, {{'Phi', self.Phi}});
                fprintf('Created predictions: %d samples.\n', self.Nt_imp);
            end
        end

        function build_grid_transfers(self, boundary)
        % Grid transfers between fine and coarse grids. The coarse grid is
        % half the fine grid in all directions. We assume a square
        % grid: nx = ny = nz.
        %
        % Computes grid transfers between a grid of size nx_prf
        % and another of size nx_prf / 2 = nx_imp
        %
        % Operators are repeated for every unknown in the grid
        %
        % boundary: empty or 'periodic'
        %
        % R: weighted restriction operator
        % P: prolongation operator

            nx_prf = self.model_prf.nx;
            nx_imp = self.model_imp.nx;
            nun = self.model_imp.nun;

            assert(nun == self.model_prf.nun, 'nun does not correspond between models');
            assert(mod(nx_prf,2) == 0);

            Nc = nx_prf / 2;
            assert(Nc == nx_imp, 'imperfect model grid size is incorrect');

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
            self.R = sparse(ico, jco, co, Nc, nx_prf);
            self.P = 2*self.R';

            if strcmp(self.dimension, '2D')
                self.R = kron(self.R,self.R);
                self.P = 4*self.R';
            end

            % repeat operator for every unknown in the grid
            I = speye(nun);
            self.R = kron(self.R, I);
            self.P = kron(self.P, I);
        end
    end
end