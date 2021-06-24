function [esn_pars, mod_pars] = distribute_params(self, exp_idx)
% Distribute hyperparameters to esn_pars, mod_pars and properties of
% Experiment.
    
% esn_pars: ESN network parameters 
% mod_pars: parameters for the Modes object (scale separation)
    
    hyp_id2value = @ (id) ...
        self.hyp_range(self.id2ind(self.hyp_ids, id), exp_idx);
    
    esn_pars.Nr          = hyp_id2value('ReservoirSize');
    mod_pars.blocksize   = hyp_id2value('BlockSize');
    self.tr_samples      = hyp_id2value('TrainingSamples');
    mod_pars.red_factor  = hyp_id2value('ReductionFactor');
    esn_pars.alpha       = hyp_id2value('Alpha');
    esn_pars.rhoMax      = hyp_id2value('RhoMax');
    esn_pars.ftAmp       = hyp_id2value('FeedthroughAmp');
    esn_pars.resAmp      = hyp_id2value('ReservoirAmp');
    esn_pars.inAmplitude = hyp_id2value('InAmplitude');
    esn_pars.avgDegree   = hyp_id2value('AverageDegree');
    esn_pars.lambda      = hyp_id2value('Lambda');
    
    esn_pars.squaredStates = ...
        self.hyp.SquaredStates.opts{hyp_id2value('SquaredStates')};
    
    esn_pars.reservoirStateInit = ...
        self.hyp.ReservoirStateInit.opts{hyp_id2value('ReservoirStateInit')};
    
    % finish the modes parameters
    mod_pars.N = self.model.N;
    mod_pars.dimension = self.dimension;
end