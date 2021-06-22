function [esn_pars, bs, samples, RF] = create_run_parameters(self, exp_idx)
    hyp_id2value = @ (id) ...
        self.hyp_range(self.id2ind(self.hyp_ids, id), exp_idx);
    
    esn_pars.Nr          = hyp_id2value('ReservoirSize');
    bs                   = hyp_id2value('BlockSize');
    samples              = hyp_id2value('TrainingSamples');
    RF                   = hyp_id2value('ReductionFactor');
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
    
end