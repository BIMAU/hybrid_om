classdef DataGen < handle
% Generates training data. Training data consists of a transient of a
% perfect model (truth) and imperfect model predictions. When the two
% models live on different grids, appropriate restriction and
% prolongation operators should be supplied. Then we also assume that
% the training data lives on the coarse grid.

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
        
        X; % stores the transient
        P; % stores the imperfect predictions
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

        function X = generate_prf_transient(self);
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
        
        function P = generate_imp_predictions(self)
        % When the size of the perfect and imperfect models differ, 
        % check that there is a suitable restriction from the perfect model grid to the
        end
    end
end