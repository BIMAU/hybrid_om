function [esn_pars, mod_pars] = distribute_params(self, exp_idx)
% Distribute hyperparameters to esn_pars, mod_pars and properties of
% Experiment.

% esn_pars: ESN network parameters
% mod_pars: parameters for the Modes object (scale separation)

% Note: all available hyp settings can be found in
% set_all_hyp_defaults. Additions should be added there and here.

    hyp_id2value = @ (id) ...
        self.hyp_range(self.id2ind(self.hyp_ids, id), exp_idx);

    esn_pars = default_esn_parameters();

    esn_pars.Nr = hyp_id2value('ReservoirSize');
    mod_pars.blocksize = hyp_id2value('BlockSize');
    self.tr_samples = hyp_id2value('TrainingSamples');
    mod_pars.red_factor = hyp_id2value('ReductionFactor');
    esn_pars.alpha = hyp_id2value('Alpha');
    esn_pars.rhoMax = hyp_id2value('RhoMax');
    esn_pars.ftAmp = hyp_id2value('FeedthroughAmp');
    esn_pars.resAmp = hyp_id2value('ReservoirAmp');
    esn_pars.inAmplitude = hyp_id2value('InAmplitude');
    esn_pars.avgDegree = hyp_id2value('AverageDegree');
    esn_pars.lambda = hyp_id2value('Lambda');
    esn_pars.waveletReduction = hyp_id2value('SVDWaveletReduction');
    esn_pars.waveletBlockSize = hyp_id2value('SVDWaveletBlockSize');

    esn_pars.squaredStates = ...
        self.hyp.SquaredStates.opts{hyp_id2value('SquaredStates')};

    esn_pars.reservoirStateInit = ...
        self.hyp.ReservoirStateInit.opts{hyp_id2value('ReservoirStateInit')};

    esn_pars.inputMatrixType = ...
        self.hyp.InputMatrixType.opts{hyp_id2value('InputMatrixType')};

    self.model_config = ...
        set_model_config(self.hyp.ModelConfig.opts{hyp_id2value('ModelConfig')});

    % finish the modes parameters
    mod_pars.N = self.model.N;
    mod_pars.dimension = self.dimension;
end

function [pars_out] = default_esn_parameters()
    pars_out                    = struct();
    pars_out                    = {};
    pars_out.scalingType        = 'standardize';
    pars_out.Nr                 = 1000;
    pars_out.rhoMax             = 0.3;
    pars_out.alpha              = 1.0;
    pars_out.Wconstruction      = 'avgDegree';
    pars_out.avgDegree          = 10;
    pars_out.lambda             = 1e-6;
    pars_out.bias               = 0.0;
    pars_out.squaredStates      = 'even';
    pars_out.reservoirStateInit = 'random';
    pars_out.inputMatrixType    = 'balancedSparse';
    pars_out.inAmplitude        = 1.0;
    pars_out.waveletBlockSize   = 1.0;
    pars_out.waveletReduction   = 1.0;
end