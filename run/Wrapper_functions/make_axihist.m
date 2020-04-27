% Writing axi.hist file
%
% For Axitra force version:
%source_index, fx_amplitude, fy_amplitude, fz_amplitude, total_amplitude, time_delay
%
%
% For Axitra moment version:
% 2 possibilities depending on the input data
%
% Moment of source.
% source_index, moment, strike, dip, rake, 0., 0., t0
%
% Slip + width + length of the source:
% source_index, slip, strike, dip, rake, width, length, t0

fid = fopen('axi.hist', 'wt');

% if source_ver == 1
%     % Force version
%     for is = 1:ns
%         fprintf(fid,'%5d %9.6f %9.3f %9.3f %9.6f %9.3f\n',source(is,1),fx(is),fy(is),fz(is),F_ampl(is),t0_delay(is));
%     end
%     
% elseif source_ver == 2
    % Moment version
   
    if moment_ver == 1
        % Given moment
        for is = 1:ns
            fprintf(fid,'%5d %12.6e %9.3f %9.3f %9.3f %9.1f %9.1f %9.4f\n',sources(is,1),Mo(is),strike(is),dip(is),rake(is),0.0,0.0,t0_delay(is));
        end
        
    else
        % Given Slip + width + len
        for is = 1:ns
            fprintf(fid,'%5d %12.6f %9.3f %9.3f %9.3f %9.6f %9.6f %9.4f\n',sources(is,1),Slip(is),strike(is),dip(is),rake(is),width(is),len(is),t0_delay(is));
        end
    end
    
%end
fclose(fid);
