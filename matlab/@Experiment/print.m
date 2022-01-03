function [] = print(self, varargin)
% only print from pid 0
    if self.pid == 0
        self.printpid(self, varargin);
    end
end