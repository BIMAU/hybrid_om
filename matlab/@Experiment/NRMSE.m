function [err, NRM] = NRMSE(self, pred, test)
% pred: predicted field
% test: testing field/truth
    
    pred = pred(:);
    test = test(:);

    self.add_field_to_memory('pred', pred);
    self.add_field_to_memory('test', test);

    diff =  self.memory.pred - self.memory.test;

    tvar =  self.memory.test - mean(self.memory.test, 2);

    T   = size(diff,2);
    N   = size(diff,1);

    if T < self.windowsize
        % padding diff with zeros
        diff = [zeros(N, self.windowsize-T), diff];
    end

    NRM = 1;
    if T > 1
        MSE   = mean(sum( diff.^2 , 1));
        NRM   = mean(sum( tvar.^2 , 1));
        NRMSE = sqrt(MSE / NRM);
        err   = NRMSE;
    else
        err = 0;
    end
end