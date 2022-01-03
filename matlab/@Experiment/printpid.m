function [] = printpid(self, varargin)
    fprintf('pid_%d: ', self.pid);
    fprintf(varargin{:});
end