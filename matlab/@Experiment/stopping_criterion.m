function [stop_flag, err] = stopping_criterion(self, predY, testY)
    [err,nrm] = self.error(predY(:), testY(:));

    % err = norm(testY(:) - predY(:)) / norm(testY(:),2);
    stop_flag = false;
    if (err > self.err_tol) && ~strcmp(self.store_state, 'all')
        stop_flag = true;
    end
end