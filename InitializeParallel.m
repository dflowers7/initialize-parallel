function varargout = InitializeParallel(numworkersperjob, funhandle, varargin)
% varargout = InitializeParallel(numworkersperjob, funhandle, varargin)

% Shut down any pools created
delete(gcp('nocreate'))

% Restart pool with desired number of workers
clu = parcluster;
clu.NumWorkers = numworkersperjob;
isstarted = false;
pausestate = pause('on');
pausereset = onCleanup(@()pause(pausestate));
retrycounter = 1;
while ~isstarted
    try
        parpool(clu);
        isstarted = true;
    catch ME
        switch ME.identifier
            case 'parallel:cluster:PoolRunValidation'
                if retrycounter > 10
                    fprintf('Starting parallel pool failed too many times! Aborting!\n')
                    rethrow(ME)
                else
                    fprintf('Starting parallel pool failed. Retrying in 10 seconds...\n')
                    pause(10)
                end
            otherwise
                rethrow(ME)
        end
    end
end

varargout = cell(nargout,1);
[varargout{:}] = funhandle(varargin{:});

end