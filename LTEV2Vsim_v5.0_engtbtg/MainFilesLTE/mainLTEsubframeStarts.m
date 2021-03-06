function [sinrManagement,stationManagement,timeManagement] = ...
            mainLTEsubframeStarts(appParams,phyParams,timeManagement,sinrManagement,stationManagement,simParams,simValues)
% an LTE subframe starts
        
% ==============
% Copyright (C) Alessandro Bazzi, University of Bologna, and Alberto Zanella, CNR
% 
% All rights reserved.
% 
% Permission to use, copy, modify, and distribute this software for any 
% purpose without fee is hereby granted, provided that this entire notice 
% is included in all copies of any software which is or includes a copy or 
% modification of this software and in all copies of the supporting 
% documentation for such software.
% 
% THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED 
% WARRANTY. IN PARTICULAR, NEITHER OF THE AUTHORS MAKES ANY REPRESENTATION 
% OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY OF THIS SOFTWARE 
% OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
% 
% Project: LTEV2Vsim
% ==============

% Compute the number of elapsed subframes (i.e., phyParams.Tsf)
timeManagement.elapsedTime_subframes = floor((timeManagement.timeNow+1e-9)/phyParams.Tsf) + 1;

% BR adopted in the time domain (i.e., TTI)
BRidT = ceil((stationManagement.BRid)/appParams.NbeaconsF);
BRidT(stationManagement.BRid<=0)=-1;

%hyeonji - RC값 잘 떨어지나 확인하는 용
if mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1 == 14
    hi = 2;
end

%hyeonji - Brid일 때 transmittingID 잘 건너뛰는 지 확인하는 용
if mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1 == 1
    hi = 1;
end

%hyeonji - elapsedTime_subframes로 txID 진짜 잘 되나
if timeManagement.elapsedTime_subframes == 201
    hi = 3;
elseif timeManagement.elapsedTime_subframes == 301
    hi = 4;
elseif timeManagement.elapsedTime_subframes == 401
    hi = 5;
end

% Find IDs of vehicles that are currently transmitting
%stationManagement.transmittingIDsLTE = find(BRidT == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1));
%mainInit에서 generationPeriod에 따라서 timeNextPacket 설정해서 이대로 가도 됨 - hj


%hyeonji - transmittingID도 뛰어 넘어 보자.
%hyeonji - 매 subframe마다 transmittingID를 정할 수 있게 되어 있음
% for i = 1:simValues.maxID
%     if stationManagement.RRIcount(i) > 1
%         stationManagement.RRIcount(i) = stationManagement.RRIcount(i) - 1;
%     elseif stationManagement.RRIcount(i) == 1
%         %stationManagement.transmittingIDsLTE2 = find(BRidT(i) == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1));
%         if find(BRidT(i) == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1))
%             stationManagement.transmittingIDsLTE = i;
%         end         
%         stationManagement.RRIcount(i) = stationManagement.RRItx(i);
%     end
% end

%hyeonji - 처음에 다 전송하는 게 아니라, RRI에 따라서 랜덤하게 전송 시작 시간을 설정할 수 있어야 함
%firstTX = ones(simValues.maxID, 1); %처음이라 RRI를 따질 필요 없음
%hyeonji - stationManagement.transmittingIDsLTE를 비워주고 시작하기
stationManagement.transmittingIDsLTE = [];
firstadd = true;
for i = 1:simValues.maxID    
    %hyeonji - RRI값에 해당하는 값에서 랜덤으로 값을 선택하여 그 시간 이후에 전송할 것이다.
%     if timeManagement.elapsedTime_subframes < stationManagement.TXtime(i,1)
%         continue;
%     else
    if (timeManagement.elapsedTime_subframes > stationManagement.TXtime(i,1)) && (timeManagement.elapsedTime_subframes <= stationManagement.TXtime(i,1) + 100)
        if find(BRidT(i) == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1)) 
%             if firstadd == true && firstTX(i,1) == 1
            if firstadd == true
                stationManagement.transmittingIDsLTE = i;
                firstadd = false;
%             elseif firstadd == false && firstTX(i,1) == 1
            elseif firstadd == false 
                txIndex = length(stationManagement.transmittingIDsLTE);
                stationManagement.transmittingIDsLTE(txIndex+1,1) = i;
            end
        end   
    elseif timeManagement.elapsedTime_subframes > stationManagement.TXtime(i,1) + 100 %한 번 전송한 상태 - hj 
        if find(BRidT(i) == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1))
           if stationManagement.RRIcount(i) > 1
               stationManagement.RRIcount(i) = stationManagement.RRIcount(i) - 1;
           elseif stationManagement.RRIcount(i) == 1
               if firstadd == true
                    stationManagement.transmittingIDsLTE = i;                    
                    firstadd = false;
               else
                   txIndex = length(stationManagement.transmittingIDsLTE);
                   stationManagement.transmittingIDsLTE(txIndex+1,1) = i;                   
               end
               stationManagement.RRIcount(i) = stationManagement.RRItx(i);
           end
        end
    else
        continue;
    end
end                
     
%     for i = 1:simValues.maxID
%         TXtime(i,1) = randi(stationManagement.TXstart(i),1,1)*100;
%     end

%hyeonji - 일단 처음에 100ms까지 한 번씩은 원래대로 전송
% firstadd = true;
% if timeManagement.elapsedTime_subframes <= 100
%     stationManagement.transmittingIDsLTE = find(BRidT == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1));
% else %hyeonji - 100ms 이후부터는 RRI가 길면 뛰어넘기
%     for i = 1:simValues.maxID
%         if find(BRidT(i) == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1))
%             if stationManagement.RRIcount(i) > 1
%                 stationManagement.RRIcount(i) = stationManagement.RRIcount(i) - 1;
%             elseif stationManagement.RRIcount(i) == 1
%                 %hyeonji - transmittingID 누적해서 추가
%                 if firstadd == true
%                     stationManagement.transmittingIDsLTE = i;
%                     firstadd = false;
%                 else
%                     txIndex = length(stationManagement.transmittingIDsLTE);
%                     stationManagement.transmittingIDsLTE(txIndex+1,1) = i;
%                 end
%                 stationManagement.RRIcount(i) = stationManagement.RRItx(i);
%             end
%         end
%     end
% end

%hyeonji - transmittingID랑 상관없이 그냥 BRid 해당하는 것만큼 RRI 당기기
%subframe마다 BRidT와 같은 것만 RRP 1씩 당기기
%shiftBRid = unique(stationManagement.BRid(find(BRidT == (mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1))));
%hyeonji - NbeaconsF = 2일 때 기준으로 짰음 달라지면 손 봐줘야 하긴 함
currentSF = mod((timeManagement.elapsedTime_subframes-1),appParams.NbeaconsT)+1;
shiftBRid = (((currentSF-1)*appParams.NbeaconsF+1):(currentSF*appParams.NbeaconsF))';
% shiftBRid2 = (currentSF*2-1 : currentSF*2)';
% if mod(currentBRidT, 2) == 0 %짝수면
%     %hyeonji - BRidT*NbeaconsF랑 BRidT*NbeaconsF-1를 circshift해야 함
%     shiftBRid = [BRidT*appParams.NbeconsF : BRidT*appParams.NbeconsF-1];
% else
%     %hyeonji - BRidT랑 BRidT*NbeaconsF를 circshift해야 함
%     shiftBRid = [BRidT : BRidT*appParams.NbeaconsF];
% end

%hyeonji - circshift 잘 되는 지
if timeManagement.elapsedTime_subframes == 200
    hi = 5;
end 
    
stationManagement.knownRRPMatrix(shiftBRid,:,:) = circshift(stationManagement.knownRRPMatrix(shiftBRid,:,:),-1,2);
stationManagement.knownRRPMatrix(shiftBRid,int8(max(timeManagement.generationInterval)*10), :) = 0;

% stationManagement.knownRRPMatrix = circshift(stationManagement.knownRRPMatrix(shiftBRid, -1, 2));%knownRRPMatrix를 RRP행 왼쪽으로 하나 옮기기
% stationManagement.knownRRPMatrix(:,int8(max(timeManagement.generationInterval)*10), :) = 0;%RRP=1인 건 시간이 지나서 지나감    
    

if ~isempty(stationManagement.transmittingIDsLTE)     
    % Find index of vehicles that are currently transmitting
    stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE = zeros(length(stationManagement.transmittingIDsLTE),1);
    stationManagement.indexInActiveIDs_OfTxLTE = zeros(length(stationManagement.transmittingIDsLTE),1);
    for ix = 1:length(stationManagement.transmittingIDsLTE)
        %A = find(stationManagement.activeIDsLTE == stationManagement.transmittingIDsLTE(ix));
        %if length(A)~=1
        %    error('X');
        %end
        stationManagement.indexInActiveIDsOnlyLTE_OfTxLTE(ix) = find(stationManagement.activeIDsLTE == stationManagement.transmittingIDsLTE(ix));
        stationManagement.indexInActiveIDs_OfTxLTE(ix) = find(stationManagement.activeIDs == stationManagement.transmittingIDsLTE(ix));
    end
end

% Initialization of the received power
[sinrManagement] = initLastPowerLTE(timeManagement,stationManagement,sinrManagement,simParams,appParams,phyParams);
    