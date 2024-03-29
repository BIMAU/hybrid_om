function [predY, corrY, testY, err, esnX, damping] = experiment_core(self)
% Core routine for running an experiment
%   predY:  full dimensional predictions (yk)
%   corrY:  full dimensional corrections (yk - Pyk)
%   testY:  full dimensional truths

    self.printpid(' train range: %d - %d\n', ...
               min(self.train_range), max(self.train_range));
    self.printpid('  test range: %d - %d\n', ...
               min(self.test_range), max(self.test_range));

    % we use the time step size of  the imperfect model
    dt  = self.data.dt_imp;

    % sample/state vector dimension, possibly reduced
    dim = size(self.VX,1);

    % sanity check
    assert(dim == size(self.modes.V,2))

    % There are several different model configurations based on settings
    % model_only, esn_only, dmd_only, hybrid_esn, hybrid_dmd,
    % corr_only, esn_plus_dmd.

    hybrid_esn = ( strcmp(self.model_config, 'hybrid_esn') );
    hybrid_dmd = ( strcmp(self.model_config, 'hybrid_dmd') );

    esn_only = ( strcmp(self.model_config, 'esn_only') );
    dmd_only = ( strcmp(self.model_config, 'dmd_only') );

    model_only = ( strcmp(self.model_config, 'model_only') );
    corr_only = ( strcmp(self.model_config, 'corr_only') );

    esn_plus_dmd = ( strcmp(self.model_config, 'esn_plus_dmd') );
    hybrid_esn_dmd = ( strcmp(self.model_config, 'hybrid_esn_dmd') );

    % only with model_only is the datadriven component ESN/DMD inactive
    esn_dmd_active = ~model_only;

    if hybrid_esn || hybrid_dmd || hybrid_esn_dmd
        % Create input/output data for hybrid ESN
        U = [self.VX(:, 1:end-1); self.VPhi(:, 1:end-1)];
        Y = [self.VX(:, 2:end)];
    elseif esn_only || dmd_only || esn_plus_dmd
        % Create input/output data for standalone ESN
        U = [self.VX(:, 1:end-1)];
        Y = [self.VX(:, 2:end)];
    elseif corr_only
        % Create input/output to only fit the correction
        U = [self.VPhi(:, 1:end-1)];
        Y = [self.VX(:, 2:end)];
    elseif model_only
    end

    tfirst = self.train_range(end)+1;
    if esn_dmd_active
        assert(tfirst == self.test_range(1), ...
               'incompatible train and test range');
        trainU = U(:, self.train_range)';
        trainY = Y(:, self.train_range)';
        clear U Y ; % clean up
    end

    % full dimensional output testing
    testY = self.data.X(:, 2:end);
    trHist = testY(:, tfirst-self.error_windowsize:tfirst-1);

    if self.testing_on
        testY = testY(:, self.test_range)';
    else
        testY = testY(:, tfirst:end)';
    end

    Npred = numel(self.test_range); % number of prediction steps
    predY = zeros(Npred, size(self.modes.V,1)); % full dimensional predictions
    corrY = zeros(Npred, size(self.modes.V,1)); % full dimensional corrections
    err   = zeros(Npred, 1); % error array
    esnX  = 0; % esn state snapshots

    % initialization index
    init_idx = self.train_range(end)+1;
    % initial state for the predictions
    yk = self.data.X(:, init_idx);

    clear self.VX self.VPhi;

    damping = 0; % Tikhonov damping array

    begin = tic;
    if esn_dmd_active
        % setup of different feedthroughs
        if hybrid_esn
            assert(size(trainU,2) == 2*dim, ...
                   'inconsistent hybrid input dimension');
            self.esn_pars.feedThrough = true;
            self.esn_pars.ftRange     = dim+1:2*dim;
        elseif hybrid_dmd || hybrid_esn_dmd
            assert(size(trainU,2) == 2*dim, ...
                   'inconsistent hybrid input dimension');
            self.esn_pars.feedThrough = true;
            self.esn_pars.ftRange     = 1:2*dim;
        elseif esn_plus_dmd || dmd_only || corr_only
            assert(size(trainU,2) == dim, ...
                   'inconsistent input dimension');
            self.esn_pars.feedThrough = true;
            self.esn_pars.ftRange     = 1:dim;
        end

        % the svd averaging overwrites svd wavelet settings
        if self.svd_averaging > 1
            self.esn_pars.waveletReduction = self.svd_averaging;
            self.esn_pars.waveletBlockSize = self.svd_averaging;
        end

        % create ESN, train the ESN and save the final state
        esn = ESN(self.esn_pars.Nr, size(trainU,2), size(trainY,2));
        esn.setPars(self.esn_pars);
        esn.initialize;

        esn.train(trainU, trainY);
        self.printpid('Training done, %.2fs\n', toc(begin));

        if ~isempty(esn.X)
            esn_state = esn.X(end,:);
        else
            esn_state = [];
        end
        damping = esn.TikhonovDamping;
    end

    clear trainU trainY

    % reset error memory
    self.error_memory = struct();
    % fill error memory with truth history
    self.error_memory.test = trHist;
    self.error_memory.pred = trHist;

    % #FIXME this should be a parameter
    verbosity = 100;
    for i = 1:Npred
        % model prediction of next time step
        try
            [Pyk, Nk] = self.model.step(yk, dt);
        catch ME
            % if a time step fails, stop this run and fill the error array
            fprintf([ME.message, '\n']);
            err(i:end) = 999;
            i = Npred;
            break;
        end

        if model_only
            % result is not adapted
            yk = Pyk;
        else
            % create an input vector for the ESN
            if hybrid_esn || hybrid_dmd || hybrid_esn_dmd
                u_in = [self.modes.Vinv * yk(:); self.modes.Vinv * Pyk(:)]';
            elseif esn_only || dmd_only || esn_plus_dmd
                u_in = [self.modes.Vinv * yk(:)]';
            elseif corr_only
                u_in = [self.modes.Vinv * Pyk(:)]';
            else
                self.printpid('no model active, doing nothing\n');
                continue
            end

            u_in      = esn.scaleInput(u_in);
            esn_state = esn.update(esn_state, u_in)';
            u_out     = esn.apply(esn_state, u_in);
            u_out     = esn.unscaleOutput(u_out);

            % transform ESN prediction back to the state space
            yk = self.modes.V * u_out(:);

            % combine ESN prediction with model prediction
            if ( strcmp(self.add_details, 'from_model') );
                yk = yk + self.modes.Vc*(self.modes.Vcinv*Pyk);
            else
                % todo
            end
        end
        % store result
        predY(i,:) = yk;

        % store correction
        corrY(i,:) = yk - Pyk;

        % check stopping criterion
        stop = false;
        if self.testing_on
            [stop, err(i)] = ...
                self.stopping_criterion(predY(i,:), testY(i,:));
        end

        if ( mod(i,verbosity) == 0 ) || ( i == Npred ) || stop
            self.printpid(['prediction step %4d/%4d, time since start %.2fs,',...
                           'Newton iterations %d,',...
                           'error %1.2e\n'], ...
                          i, Npred, toc(begin), Nk, err(i));
        end

        if stop
            break;
        end
    end

    % truncate output arrays
    predY = predY(1:i,:);
    corrY = corrY(1:i,:);
    if self.testing_on
        testY = testY(1:i,:);
    end
    err = err(1:i);
end