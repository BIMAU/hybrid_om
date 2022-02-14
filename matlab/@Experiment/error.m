function [err, nrm] = error(self, pred, test)
% pred: predicted field
% test: testing field/truth
    
    err = 0;

    pred = pred(:);
    test = test(:);

    % add prediction and test field to memory
    self.add_field_to_memory('pred', pred);
    self.add_field_to_memory('test', test);

    diff = self.error_memory.pred - self.error_memory.test;

    T   = size(diff,2);
    N   = size(diff,1);
    assert(T == size(self.error_memory.test,2));
    assert(T == self.error_windowsize);

    if strcmp(self.err_type, 'nrmse');
        assert(T > 1, 'no window for NRMSE, unable to compute');
        tvar = self.error_memory.test - mean(self.error_memory.test, 2);

        mse = mean(sum( diff.^2 , 1));
        nrm = mean(sum( tvar.^2 , 1));
        err = sqrt(mse / nrm);

    elseif strcmp(self.err_type, 'norm')
        nrm = zeros(1,T);
        for j = 1:T
            nrm(1,j) = norm(self.error_memory.test(:,j),2)^2;
        end
        nrm = sqrt(mean(nrm));
        err = norm(pred-test,2) / nrm;
    else
        error('no error specified');
    end
end