clc
clear

%generate data %two inputs and one input
NumDMU=50;
x1Lower=0;x2Lower=0;
x1Upper=1;x2Upper=1;
zShift=0.05;%constant upper shift for all DMU above the threshold hyperplane

mInput=[unifrnd(x1Lower,x1Upper,NumDMU,1),unifrnd(x2Lower,x2Upper,NumDMU,1)];
%mOutput=mInput*[1;2]+lognrnd(0,0.5,NumDMU,1);
mOutput=mInput*[1;2]+unifrnd(-0.5,0.5,NumDMU,1);
xlswrite('exp1Data.xls',mInput,'input');
xlswrite('exp1Data.xls',mOutput,'output');

%readdate
% mInput=xlsread('exp1Data.xls','input');
% mOutput=xlsread('exp1Data.xls','output');

save abc
load abc

if size(mInput,1)~=size(mOutput,1)
    error('The input matrix and the output matrix must has the same number of rows!')
end
if size(mInput,2)~=2
    error('In the experiment, the number of inputs must be 2!!!')   
end
if size(mOutput,2)~=1
    error('In the experiment, the number of outputs must be 1!!!')   
end
OrgData=[mInput,mOutput];

%settings for gurobi optimization

params.IntFeasTol=1e-9;
params.MIPGap=0;
params.MIPGapAbs=0;
params.TimeLimit=600;
params.MIPFocus=2;

%found a DMU with rank at least 5
Rank=1;iDMUo=0;
while (iDMUo<NumDMU)
    iDMUo=iDMUo+1;
    if (abs(OrgData(iDMUo,1)-x1Lower/2-x1Upper/2)>(x1Upper-x1Lower)/5)|abs(OrgData(iDMUo,2)-x2Lower/2-x2Upper/2)>(x2Upper-x2Lower)/5
        continue
    end
    [Rank1,RunTime,vOptNu,vOptMu]=BestTechRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
    if (vOptNu(1)==0)|(vOptNu(2)==0)|(vOptMu==0)
        continue
    end
    [Rank2,RunTime,vOptNu,vOptMu]=BestEcoRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
    if (vOptNu(1)==0)|(vOptNu(2)==0)|(vOptMu==0)
        continue
    end
    [Rank3,RunTime,ApproxRank,vOptNu,vOptMu]=BestEcoBuffRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
    if (vOptNu(1)==0)|(vOptNu(2)==0)|(vOptMu==0)
        continue
    end
    break
end
if (iDMUo==NumDMU)
    error('Fail to find DMU for illustration.')
end

%-----TechRank  Begin----------------------------------------------------
[Rank,RunTime,vOptNuBeforeD,vOptMuBeforeD]=BestTechRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
DataDMUo=OrgData(iDMUo,:);%store the DMUo
DataDeleteDMUo=[OrgData(1:(iDMUo-1),:);OrgData((iDMUo+1):NumDMU,:)]; %store other DMUs
EstRatios=(DataDeleteDMUo(:,3)*vOptMuBeforeD)./(DataDeleteDMUo(:,1:2)*vOptNuBeforeD);
data=[EstRatios,DataDeleteDMUo];
sortedData=sortrows(data,1,'descend');
DataShare=[sortedData(1:(Rank-1),2:4);sortedData((Rank+1):end,2:4)];
DataBeforeD=sortedData(Rank,2:4);
DataAfterUp=[DataBeforeD(:,1:2),DataBeforeD(:,3)*(1+zShift)];
mInput=[DataDMUo(:,1:2);DataAfterUp(:,1:2);DataShare(:,1:2)];
mOutput=[DataDMUo(:,3);DataAfterUp(:,3);DataShare(:,3)];
[RankUp,RunTime,vOptNuAfterUp,vOptMuAfterUp]=BestTechRankOpt(mInput,mOutput,1,params);
[vOptNuBeforeD',vOptMuBeforeD;vOptNuAfterUp',vOptMuAfterUp]

f1=figure;
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataBeforeD(:,1),DataBeforeD(:,2),DataBeforeD(:,3),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',0.2);
scatter3(DataAfterUp(:,1),DataAfterUp(:,2),DataAfterUp(:,3),'k','LineWidth',0.2);
xlabel('Input1')
ylabel('Input2')
zlabel('Output')
axis([x1Lower x1Upper x2Lower x2Upper 0 max(mOutput)]);
xLim = [x1Lower,x1Upper];
yLim = [x2Lower,x2Upper];
[X,Y] = meshgrid(xLim,yLim);
ratio=(OrgData(iDMUo,3)*vOptMuBeforeD)/(OrgData(iDMUo,1:2)*vOptNuBeforeD);
Z=ratio*(vOptNuBeforeD(1)*X+vOptNuBeforeD(2)*Y)/vOptMuBeforeD;
reOrder = [1 2  4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'c');
alpha(1);
ratio=(OrgData(iDMUo,3)*vOptMuAfterUp)/(OrgData(iDMUo,1:2)*vOptNuAfterUp);
Z=ratio*(vOptNuAfterUp(1)*X+vOptNuAfterUp(2)*Y)/vOptMuAfterUp;
reOrder = [1 2  4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'m');
alpha(1);
%-----TechRank  End---------------------------------------------------


%-----EcoRank  Begin----------------------------------------------------
[Rank,RunTime,vOptNuBeforeD,vOptMuBeforeD]=BestEcoRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
DataDMUo=OrgData(iDMUo,:);%store the DMUo
DataDeleteDMUo=[OrgData(1:(iDMUo-1),:);OrgData((iDMUo+1):NumDMU,:)]; %store other DMUs
EstProfits=DataDeleteDMUo(:,3)*vOptMuBeforeD-DataDeleteDMUo(:,1:2)*vOptNuBeforeD;
data=[EstProfits,DataDeleteDMUo];
sortedData=sortrows(data,1,'descend');
DataShare=[sortedData(1:(Rank-1),2:4);sortedData((Rank+1):end,2:4)];
DataBeforeD=sortedData(Rank,2:4);
DataAfterUp=[DataBeforeD(:,1:2),DataBeforeD(:,3)+zShift];
mInput=[DataDMUo(:,1:2);DataAfterUp(:,1:2);DataShare(:,1:2)];
mOutput=[DataDMUo(:,3);DataAfterUp(:,3);DataShare(:,3)];
[RankUp,RunTime,vOptNuAfterUp,vOptMuAfterUp]=BestEcoRankOpt(mInput,mOutput,1,params);

%plot
f3=figure;
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataBeforeD(:,1),DataBeforeD(:,2),DataBeforeD(:,3),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',0.2);
scatter3(DataAfterUp(:,1),DataAfterUp(:,2),DataAfterUp(:,3),'k','LineWidth',0.2);
xlabel('Input1')
ylabel('Input2')
zlabel('Output')
axis([x1Lower x1Upper x2Lower x2Upper 0 max(mOutput)]);
xLim = [x1Lower,x1Upper];
yLim = [x2Lower,x2Upper];
[X,Y] = meshgrid(xLim,yLim);
D=OrgData(iDMUo,3)*vOptMuBeforeD-OrgData(iDMUo,1:2)*vOptNuBeforeD;
Z=(vOptNuBeforeD(1)*X+vOptNuBeforeD(2)*Y+D)/vOptMuBeforeD;
reOrder = [1 2  4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'c');
alpha(1);
D=OrgData(iDMUo,3)*vOptMuAfterUp-OrgData(iDMUo,1:2)*vOptNuAfterUp;
Z=(vOptNuAfterUp(1)*X+vOptNuAfterUp(2)*Y+D)/vOptMuAfterUp;
reOrder = [1 2  4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'m');
alpha(1);
%-----EcoRank  End--------------------------------------------------------

%-----EcoBuffRank  Begin----------------------------------------------------
[BuffRankBeforeD,RunTime,ApproxRank,vOptNuBeforeD,vOptMuBeforeD]=BestEcoBuffRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
DataDMUo=OrgData(iDMUo,:);%store the DMUo
Rank=sum((OrgData(:,3)*vOptMuBeforeD-OrgData(:,1:2)*vOptNuBeforeD)>(DataDMUo(3)*vOptMuBeforeD-DataDMUo(1:2)*vOptNuBeforeD))+1;
DataDeleteDMUo=[OrgData(1:(iDMUo-1),:);OrgData((iDMUo+1):NumDMU,:)]; %store other DMUs
EstProfits=DataDeleteDMUo(:,3)*vOptMuBeforeD-DataDeleteDMUo(:,1:2)*vOptNuBeforeD;
data=[EstProfits,DataDeleteDMUo];
sortedData=sortrows(data,1,'descend');
DataShare=[sortedData(1:(Rank-1),2:4);sortedData((Rank+1):end,2:4)];
DataBeforeD=sortedData(Rank,2:4);
DataAfterUp=[DataBeforeD(:,1:2),DataBeforeD(:,3)+zShift];
mInput=[DataDMUo(:,1:2);DataAfterUp(:,1:2);DataShare(:,1:2)];
mOutput=[DataDMUo(:,3);DataAfterUp(:,3);DataShare(:,3)];
[BuffRankAfterUp,RunTime,ApproxRank,vOptNuAfterUp,vOptMuAfterUp]=BestEcoBuffRankOpt(mInput,mOutput,1,params);
[[vOptNuBeforeD',vOptMuBeforeD]/vOptMuBeforeD;[vOptNuAfterUp',vOptMuAfterUp]/vOptMuAfterUp]

f5=figure;
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataBeforeD(:,1),DataBeforeD(:,2),DataBeforeD(:,3),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',0.2);
scatter3(DataAfterUp(:,1),DataAfterUp(:,2),DataAfterUp(:,3),'k','LineWidth',0.2);
xlabel('Input1')
ylabel('Input2')
zlabel('Output')
axis([x1Lower x1Upper x2Lower x2Upper 0 max(mOutput)]);
xLim = [x1Lower,x1Upper];
yLim = [x2Lower,x2Upper];
[X,Y] = meshgrid(xLim,yLim);
EstProfitD=sort(OrgData(:,3)*vOptMuAfterUp-OrgData(:,1:2)*vOptNuAfterUp,'descend');
if (floor(BuffRankAfterUp)==BuffRankAfterUp)
    D=EstProfitD(floor(BuffRankAfterUp));
else
    D=EstProfitD(floor(BuffRankAfterUp))-(EstProfitD(floor(BuffRankAfterUp))-EstProfitD(floor(BuffRankAfterUp)+1))*(BuffRankAfterUp-floor(BuffRankAfterUp));
end
Z=(vOptNuAfterUp(1)*X+vOptNuAfterUp(2)*Y+D)/vOptMuAfterUp;
reOrder = [1 2 4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'m');
alpha(1);
EstProfitD=sort(OrgData(:,3)*vOptMuBeforeD-OrgData(:,1:2)*vOptNuBeforeD,'descend');
if (floor(BuffRankBeforeD)==BuffRankBeforeD)
    D=EstProfitD(floor(BuffRankBeforeD));
else
    D=EstProfitD(floor(BuffRankBeforeD))-(EstProfitD(floor(BuffRankBeforeD))-EstProfitD(floor(BuffRankBeforeD)+1))*(BuffRankBeforeD-floor(BuffRankBeforeD));
end
Z=(vOptNuBeforeD(1)*X+vOptNuBeforeD(2)*Y+D)/vOptMuBeforeD;
reOrder = [1 2 4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'c');
alpha(1);
%-----EcoBuffRank  End--------------------------------------------------------

set(f1,'Position',[100 100 500 400])
set(f3,'Position',[100 100 500 400])
set(f5,'Position',[100 100 500 400])
saveas(f1,'TechRank21.eps','epsc');
saveas(f3,'EcoRank21.eps','epsc');
saveas(f5,'EcoBuffRank21.eps','epsc');
close all















