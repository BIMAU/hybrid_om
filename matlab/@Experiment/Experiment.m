classdef Experiment < handle
% Experiment class that creates hybrid DMD/ESN setups and performs
% training and prediction for many training data sets and many
% realizations of the random ESN operators W and Win. It stores a
% collection of ESN hyperparameters that we like to experiment with.

    properties (Access = public)

        shifts = 5;   % shifts in training_range
        reps   = 3;   % repetitions per shift

        max_preds = 10; % prediction barrier (in samples)

        testing_on = true; % if true/false we run the prediction with/without
                           % generating errors w.r.t. the truth.

        % Model configuration.
        model_config = 'hybrid_esn';

        % Scale separation (modes)
        scale_separation = 'none';

        % How to add details
        add_details = 'from_model';

        store_state = 'final'; % which state to store: 'all', 'final', 'stats'

        dimension = '1D'; % problem dimension: '1D' or '2D'

        err_tol = 0.5; % error tolerance in stopping criterion

        % Modes object used for scale separation and order reduction
        modes;

        % Problem identifier
        ident = 'default';

        % set the window size for the nrs
        nrmse_windowsize = 50;

        % set the window size for Km, Ke, Z (qg only)
        stats_windowsize = 50;

        % y-axis label
        ylab = 'samples';

        % use the svd wavelet interface in ESN to average the data
        svd_averaging = 1;
    end

    properties (Access = private)
        data; % training data object
        model; % model object

        hyp; % hyperparameter collection
        name; % experiment name

        % default serial setting
        pid   = 0;
        procs = 1;

        % hyperparam identifier strings
        hyp_ids;

        % All hyperparam settings
        hyp_range;

        % Total number of different hyperparam settings.
        num_hyp_settings;

        % Experiment descriptor for output file
        file_descr;

        exp_id  = {}; % experiment identifiers
        exp_ind = []; % experiment identifier index

        range2str = @ (range) ['_', num2str(range(1)), ...
                            '-', num2str(range(end)), '_'];

        id2ind  = @ (hyp_ids, str) find(strcmp(hyp_ids, str));

        % data storage for all runs
        predictions; % stores all predictions
        truths; % stores all truths
        errors; % stores the errors
        ESN_states; % stores snapshots of the ESN state X
        damping; % stores SVD damping curves
        spectra; % stores yearly average spectrum (1st component) and variance
                 % (2nd component), qg only
        stats; % stores statistics (Km, Ke, Z, ...), qg only

        % generated parameters of for the ESN
        esn_pars;

        % Number of predicted time steps that are within the error limit.
        num_predicted;

        % Number of training samples
        tr_samples;

        % Range of the training samples
        train_range;

        % Range of the test samples
        test_range;

        % Temporary variables to store transformed states and imperfect
        % predictions
        VX;
        VPhi;

        % A memory with a windowsize is needed to be able to compute a NRMSE
        nrmse_memory = struct();

        % output_directory
        output_dir = '';

    end

    methods (Access = public)

        function self = Experiment(data, pid, procs)
        % constructor
        %
        % data:     training data object
        % pid:      process id
        % procs:    total number of processes

            self.data      = data;
            self.model     = data.model_imp;
            self.dimension = data.dimension;

            switch nargin
              case 2
                self.pid = pid;
              case 3
                self.pid   = pid;
                self.procs = procs;
            end

            % Seed the rng with time and pid
            now = clock;
            rng(round(100*self.pid*sqrt(now(end))));

            self.print('\n')
            self.print('Experiment instance\n')
            self.print(' procs  = %d \n', self.procs)
            self.print(' pid    = %d \n', self.pid)

            self.set_all_hyp_defaults();
         end

         function [dir] = run(self)
            time = tic;

            assert(~isempty(self.exp_id), 'no experiment added');

            % initialize
            self.create_descriptors();
            self.create_hyp_range();
            self.create_storage();
            self.create_output_dir();

            % number of time steps in series
            Nt = size(self.data.X, 2);

            % largest requested number of training samples
            max_tr_samples = self.max_available_hyp('TrainingSamples');

            % create shifts in the training data
            % -1 to make sure there is output training data
            if self.testing_on
                max_shift = Nt - self.max_preds - max_tr_samples - 1;
            else
                max_shift = Nt - max_tr_samples - 1;
            end
            assert(max_shift > 1, 'invalid number of training samples, choose less');

            if self.shifts > 1
                tr_shifts = round(linspace(0, max_shift, self.shifts));
            else
                tr_shifts = 0;
            end

            % The core experiment is repeated with <reps>*<shifts> realizations of
            % the network. The range of the training data changes with <shifts>.
            cvec = combvec((1:self.reps), (1:self.shifts))';
            rvec = cvec(:,1);
            svec = cvec(:,2);
            Ni = numel(svec); % number of indices

            % combination of shifts and hyperparameter settings
            reps_hyps = combvec(1:Ni, 1:self.num_hyp_settings)';

            % total number of independent experiments
            Ntotal = size(reps_hyps,1);

            % domain decomposition
            my_inds = self.my_indices(self.pid, self.procs, Ntotal);

            my_reps_hyps = reps_hyps(my_inds, :);

            for it = my_inds

                i = reps_hyps(it,1);
                j = reps_hyps(it,2);

                [self.esn_pars, mod_pars] = self.distribute_params(j);

                self.print_hyperparams(j);
                self.printpid('hyp setting: %d/%d shift: %d/%d repetitions: %d/%d \n', ...
                              j, self.num_hyp_settings, ...
                              svec(i), self.shifts, ...
                              rvec(i), self.reps);

                self.train_range = (1:self.tr_samples) + tr_shifts(svec(i));
                self.test_range  = self.train_range(end) + (1:self.max_preds);

                self.modes = Modes(self.scale_separation, mod_pars, ...
                                   self.data, self.train_range);

                self.VX   = self.modes.Vinv * self.data.X;
                self.VPhi = self.modes.Vinv * self.data.Phi;

                [predY, testY, err, esnX, damping] = self.experiment_core();

                self.num_predicted(i, j) = size(predY, 1);

                self.damping{i, j} = damping;
                if strcmp(self.store_state, 'all')
                    self.predictions{i, j} = predY(:,:);
                    if ~isempty(testY)
                        self.truths{i, j} = testY(:,:);
                    end
                    self.ESN_states{i,j} = esnX(round(linspace(1,size(esnX,1),20)),:);

                elseif strcmp(self.store_state, 'final');
                    self.predictions{i, j} = predY(end,:);

                    if ~isempty(testY)
                        self.truths{i, j} = testY(end,:);
                    end

                    self.ESN_states{i,j} = esnX(end,:);

                elseif strcmp(self.store_state, 'stats');
                    self.predictions{i, j} = predY(end,:);
                    if ~isempty(testY)
                        self.truths{i, j} = testY(end,:);
                    end
                    self.ESN_states{i,j} = esnX(end,:);
                    [Pm, Pv] = Utils.get_qg_yearly_spectrum(self.model, predY');
                    self.spectra{i,j,1} = Pm;
                    self.spectra{i,j,2} = Pv;
                    stat_opts.windowsize = self.stats_windowsize;
                    self.stats{i,j} = ...
                        Utils.get_qg_statistics(self.model, predY', stat_opts);
                else
                    error('Unexpected input');
                end
                self.errors{i, j} = err;

                xlab = self.exp_id;

                % name-value pairs:
                % add whatever is useful here and use a meaningful name
                pairs = { {'my_inds', my_inds}, ...
                          {'my_reps_hyps', my_reps_hyps}, ...
                          {'hyp_range', self.hyp_range}, ...
                          {'hyp', self.hyp}, ...
                          {'exp_id', self.exp_id}, ...
                          {'exp_ind', self.exp_ind}, ...
                          {'xlab', xlab}, ...
                          {'ylab', self.ylab}, ...
                          {'num_predicted', self.num_predicted}, ...
                          {'errs', self.errors}, ...
                          {'predictions', self.predictions}, ...
                          {'truths', self.truths}, ...
                          {'test_range', self.test_range}, ...
                          {'train_range', self.train_range}, ...
                          {'testing_on', self.testing_on}, ...
                          {'model_config', self.model_config}, ...
                          {'esn_pars', self.esn_pars}, ...
                          {'ESN_states', self.ESN_states}, ...
                          {'damping', self.damping}, ...
                          {'spectra', self.spectra}, ...
                          {'stats', self.stats}};

                self.store_results(pairs);
            end
            self.printpid('done (%fs)\n', toc(time));
            dir = self.output_dir;
        end

        function set_default_hyp(self, id, value)
        % adjust the default value of a hyperparameter
            assert(isfield(self.hyp, id), ['id ', id, ' is not a hyperparameter']);
            self.hyp.(id).default = value;
        end

        function add_experiment(self, id, range)
        % Add an experiment: give a hyperparameter id and the range of values
        % of interest.

            self.exp_id = {self.exp_id{:}, id}; % append experiment id
            self.hyp.(id).range = range;        % set range

            % adjust hyperparam description
            str = self.hyp.(id).descr;
            self.hyp.(id).descr = [str(1:2), self.range2str(range)];

            assert( numel(self.exp_id) <= 2, ...
                    ['combining 3 or more experiments ', ...
                     'is not yet supported by the plotting routines'] );
        end
    end
    methods (Access = private)

        [] = set_all_hyp_defaults(self);
        [] = create_descriptors(self);
        [] = create_hyp_range(self);
        [] = create_storage(self);

        [inds] = my_indices(self, pid, procs, Ni);

        [] = print(self, varargin);
        [] = printpid(self, varargin);

        [] = print_hyperparams(self, exp_idx);
        [esn_pars, mod_pars] = distribute_params(self, exp_idx);

        [err, nrm] = nrmse(self, pred, test);

        [] = add_field_to_memory(self, name, field);

        [predY, testY, err, esnX, damping] = experiment_core(self);

        [stop_flag, err] = stopping_criterion(self, predY, testY);

        [] = create_output_dir(self);
        [dir] = store_results(self, pairs);

        [value] = max_available_hyp(self, name);
    end
end