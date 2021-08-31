function [predY, testY, err, esnX, damping] = experiment_core(self)
% Core routine for running an experiment
%   predY:  full dimensional predictions
%   testY:  full dimensional truths

    self.print(' train range: %d - %d\n', ...
               min(self.train_range), max(self.train_range));
    self.print('  test range: %d - %d\n', ...
               min(self.test_range), max(self.test_range));

    % we use the time step size of  the imperfect model
    dt  = self.data.dt_imp;

    % sample/state vector dimension, possibly reduced
    dim = size(self.VX,1);

    % sanity check
    assert(dim == size(self.modes.V,2))

    % three different experiments based on settings
    hybrid     = logical( (self.esn_on   == true ) && ...
                          (self.model_on == true ) );
    esn_only   = logical( (self.esn_on   == true ) && ...
                          (self.model_on == false) );
    model_only = logical( (self.esn_on   == false) && ...
                          (self.model_on == true ) );

    if hybrid
        self.print('Create input/output data for hybrid ESN\n');
        exp_type = 'hybrid';
        U = [self.VX(:, 1:end-1); self.VPhi(:, 1:end-1)];
        Y = [self.VX(:, 2:end)];
    elseif esn_only
        self.print('Create input/output data for standalone ESN\n')
        exp_type = 'esn_only';
        U = [self.VX(:, 1:end-1)];
        Y = [self.VX(:, 2:end)];
    elseif model_only
        exp_type = 'model_only';
    end

    if self.esn_on
        assert(self.train_range(end)+1 == self.test_range(1), ...
               'incompatible train and test range');
        trainU = U(:, self.train_range)';
        trainY = Y(:, self.train_range)';
        clear U Y ; % clean up
    end

    % full dimensional output testing
    if self.testing_on
        testY = self.data.X(:, 2:end);
        testY = testY(:, self.test_range)';
    else
        testY = [];
    end

    Npred = numel(self.test_range); % number of prediction steps
    predY = zeros(Npred, dim); % full dimensional predictions
    err   = zeros(Npred, 1); % error array
    esnX  = 0; % esn state snapshots

    % initial state for the predictions
    init_idx = self.train_range(end)+1;
    yk = self.data.X(:, init_idx);

    self.print('initialization index: %d\n', init_idx);

    clear self.VX self.VPhi;
    
    damping = 0;
    if self.esn_on
        % enable hybrid input design
        if hybrid
            assert(size(trainU,2) == 2*dim, ...
                   'inconsistent hybrid input dimension');
            self.esn_pars.feedThrough = true;
            self.esn_pars.ftRange     = dim+1:2*dim;
        end

        % create ESN, train the ESN and save the final state
        esn = ESN(self.esn_pars.Nr, size(trainU,2), size(trainY,2));
        esn.setPars(self.esn_pars);
        esn.initialize;
        esn.train(trainU, trainY);        
        esn_state = esn.X(end,:);
        esnX = esn.X;
        damping = esn.TikhonovDamping;        
    end

    clear trainU trainY

    % reset memory for nrmse
    self.nrmse_memory = struct();
    verbosity = 100;
    for i = 1:Npred
        % model prediction of next time step
        [Pyk, Nk] = self.model.step(yk, dt);

        if model_only
            % result is not adapted
            yk = Pyk;
        else
            % create an input vector for the ESN
            if hybrid
                u_in = [self.modes.V' * yk(:); self.modes.V' * Pyk(:)]';
            elseif esn_only
                u_in = [self.modes.V' * yk(:)]';
            else
                fprintf('no model active, doing nothing\n');
                continue
            end
            
            u_in      = esn.scaleInput(u_in);
            esn_state = esn.update(esn_state, u_in)';
            u_out     = esn.apply(esn_state, u_in);
            u_out     = esn.unscaleOutput(u_out);

            % transform ESN prediction back to the state space
            yk = self.modes.V * u_out(:);

            % combine ESN prediction with model prediction
            % yk = yk + Vc*(Vc'*Pyk); % TODO
        end

        % store result
        predY(i,:) = yk;

        % check stopping criterion
        stop = false;
        if self.testing_on
            [stop, err(i)] = ...
                self.stopping_criterion(predY(i,:), testY(i,:));
        end


        if (mod(i,verbosity) == 0) || (i == Npred) || stop
            self.print(['prediction step %4d/%4d, Newton iterations %d,',...
                        'error %1.2e, %s\n'], ...
                       i, Npred, Nk, err(i), exp_type);
        end
        
        if stop
            break;
        end
    end

    % truncate output arrays
    predY = predY(1:i,:);
    if self.testing_on
        testY = testY(1:i,:);
    end
    err = err(1:i);

end