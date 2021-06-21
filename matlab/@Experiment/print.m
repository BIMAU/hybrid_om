function [] = print(self, varargin)
% only print form pid 0
    if self.pid == 0
        fprintf(varargin{:});
    end
end