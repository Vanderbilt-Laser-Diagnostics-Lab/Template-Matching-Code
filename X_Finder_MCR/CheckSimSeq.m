function [rmsError] = CheckSimSeq(SeqOut)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

for i = 1:size(SeqOut,3)
    badrows = SeqOut(:,3,i) == 0;
    SeqOut(badrows,3:4,i) = NaN;
    
    [u v] = DisplaceFun(SeqOut(:,1,i), SeqOut(:,2,i));
    
    Error = [u v] - SeqOut(:,3:4,i);
%     rmsE(i,:) = nanstd(Error,1);
    rmsE(i,:) = nanstd(SeqOut(:,3:4,i),1);
    maxE(i,:) = nanmax(abs(Error));
end

for i = 1:5
    rmsError(i,:) = mean(rmsE((i-1)*10+1:(i)*10,:).^2).^.5;
end

end