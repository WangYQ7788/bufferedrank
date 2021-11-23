%generate data %two inputs and one input
NumDMU=100;
x1Lower=0;x2Lower=0;
x1Upper=1;x2Upper=1;
zShift=0.5;%constant upper shift for all DMU above the threshold hyperplane
VerySmall=10^(-8);

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

%-----EcoBuffRank  Begin----------------------------------------------------
[BuffRankBeforeD,RunTime,ApproxRank,vOptNuBeforeD,vOptMuBeforeD]=BestEcoBuffRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
DataDMUo=OrgData(iDMUo,:);%store the DMUo
DataDeleteDMUo=[OrgData(1:(iDMUo-1),:);OrgData((iDMUo+1):NumDMU,:)]; %store other DMUs
EstProfit=DataDeleteDMUo(:,3)*vOptMuBeforeD-DataDeleteDMUo(:,1:2)*vOptNuBeforeD;
Rank=sum(EstProfit>DataDMUo(3)*vOptMuBeforeD-DataDMUo(1:2)*vOptNuBeforeD)+1;
data=[EstProfit,DataDeleteDMUo];
sortedData=sortrows(data,1,'descend');
DataShare=sortedData(Rank:(NumDMU-1),2:4);
DataBeforeD=sortedData(1:(Rank-1),2:4);
DataAfterD=[DataBeforeD(:,1:2),DataBeforeD(:,3)+zShift];
mInput=[DataDMUo(:,1:2);DataAfterD(:,1:2);DataShare(:,1:2)];
mOutput=[DataDMUo(:,3);DataAfterD(:,3);DataShare(:,3)];
x0=max(0,ones(NumDMU,1)+[-mInput+ones(NumDMU,1)*mInput(iDMUo,:)]*vOptNuBeforeD+[mOutput-ones(NumDMU,1)*mOutput(iDMUo,:)]*vOptMuBeforeD);
x0=[x0;vOptNuBeforeD;vOptMuBeforeD];
[BuffRankAfterD,RunTime,ApproxRank,vOptNuAfterD,vOptMuAfterD]=BestEcoBuffRankOpt(mInput,mOutput,1,params,x0);

%plots
f5=figure;
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataBeforeD(:,1),DataBeforeD(:,2),DataBeforeD(:,3),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',0.2);
xlabel('Input1')
ylabel('Input2')
zlabel('Output')
axis([x1Lower x1Upper x2Lower x2Upper 0 max(mOutput)]);
xLim = [x1Lower,x1Upper];
yLim = [x2Lower,x2Upper];
[X,Y] = meshgrid(xLim,yLim);
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

f6=figure
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataAfterD(:,1),DataAfterD(:,2),DataAfterD(:,3),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'LineWidth',0.2);
xlabel('Input1')
ylabel('Input2')
zlabel('Output')
patch(X(reOrder),Y(reOrder),Z(reOrder),'c');
axis([x1Lower x1Upper x2Lower x2Upper 0 max(mOutput)]);
diff=max(mOutput)-min(mOutput);
xLim = [x1Lower,x1Upper];
yLim = [x2Lower,x2Upper];
[X,Y] = meshgrid(xLim,yLim);
EstProfitD=sort(OrgData(:,3)*vOptMuAfterD-OrgData(:,1:2)*vOptNuAfterD,'descend');
if (floor(BuffRankAfterD)==BuffRankAfterD)
    D=EstProfitD(floor(BuffRankAfterD));
else
    D=EstProfitD(floor(BuffRankAfterD))-(EstProfitD(floor(BuffRankAfterD))-EstProfitD(floor(BuffRankAfterD)+1))*(BuffRankAfterD-floor(BuffRankAfterD));
end
Z=(vOptNuBeforeD(1)*X+vOptNuBeforeD(2)*Y+D)/vOptMuBeforeD;
reOrder = [1 2 4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'m');
alpha(1);
%-----EcoBuffRank  End--------------------------------------------------------


%-----EcoRank  Begin----------------------------------------------------
[Rank,RunTime,vOptNuBeforeD,vOptMuBeforeD]=BestEcoRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
DataDMUo=OrgData(iDMUo,:);%store the DMUo
DataDeleteDMUo=[OrgData(1:(iDMUo-1),:);OrgData((iDMUo+1):NumDMU,:)]; %store other DMUs
EstProfit=DataDeleteDMUo(:,3)*vOptMuBeforeD-DataDeleteDMUo(:,1:2)*vOptNuBeforeD;
data=[EstProfit,DataDeleteDMUo];
sortedData=sortrows(data,1,'descend');
DataShare=sortedData(Rank:(NumDMU-1),2:4);
DataBeforeD=sortedData(1:(Rank-1),2:4);
DataAfterD=[DataBeforeD(:,1:2),DataBeforeD(:,3)+zShift];
mInput=[DataDMUo(:,1:2);DataAfterD(:,1:2);DataShare(:,1:2)];
mOutput=[DataDMUo(:,3);DataAfterD(:,3);DataShare(:,3)];
[Rank2,RunTime,vOptNuAfterD,vOptMuAfterD]=BestEcoRankOpt(mInput,mOutput,1,params);
EstProfit=mOutput*vOptMuBeforeD-mInput(:,1:2)*vOptNuBeforeD;
Rank3=sum(EstProfit>EstProfit(1)+VerySmall)+1;
if Rank2==Rank3
    vOptNuAfterD=vOptNuBeforeD;
    vOptMuAfterD=vOptMuBeforeD;
else
    save abc
    error('Something wrong!! Possible numerical error.....')
end

%plot
f3=figure;
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataBeforeD(:,1),DataBeforeD(:,2),DataBeforeD(:,3),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',0.2);
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


f4=figure
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataBeforeD(:,1),DataAfterD(:,2),DataAfterD(:,3),'k','LineWidth',0.2);
xlabel('Input1')
ylabel('Input2')
zlabel('Output')
axis([x1Lower x1Upper x2Lower x2Upper 0 max(mOutput)]);
xLim = [x1Lower,x1Upper];
yLim = [x2Lower,x2Upper];
[X,Y] = meshgrid(xLim,yLim);
D=OrgData(iDMUo,3)*vOptMuAfterD-OrgData(iDMUo,1:2)*vOptNuAfterD;
Z=(vOptNuAfterD(1)*X+vOptNuAfterD(2)*Y+D)/vOptMuAfterD;
reOrder = [1 2  4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'c');
alpha(1);
%-----EcoRank  End--------------------------------------------------------

%-----TechRank  Begin----------------------------------------------------
[Rank,RunTime,vOptNuBeforeD,vOptMuBeforeD]=BestTechRankOpt(OrgData(:,1:2),OrgData(:,3),iDMUo,params);
DataDMUo=OrgData(iDMUo,:);%store the DMUo
DataDeleteDMUo=[OrgData(1:(iDMUo-1),:);OrgData((iDMUo+1):NumDMU,:)]; %store other DMUs
EstRatios=(DataDeleteDMUo(:,3)*vOptMuBeforeD)./(DataDeleteDMUo(:,1:2)*vOptNuBeforeD);
data=[EstRatios,DataDeleteDMUo];
sortedData=sortrows(data,1,'descend');
DataShare=sortedData(Rank:(NumDMU-1),2:4);
DataBeforeD=sortedData(1:(Rank-1),2:4);
DataAfterD=[DataBeforeD(:,1:2),DataBeforeD(:,3)*(1+zShift)]
mInput=[DataDMUo(:,1:2);DataAfterD(:,1:2);DataShare(:,1:2)];
mOutput=[DataDMUo(:,3);DataAfterD(:,3);DataShare(:,3)];
[Rank2,RunTime,vOptNuAfterD,vOptMuAfterD]=BestTechRankOpt(mInput,mOutput,1,params);
%possible multiple optimal solutions
EstRatios=(mOutput*vOptMuBeforeD)./(mInput(:,1:2)*vOptNuBeforeD);
Rank3=sum(EstRatios>EstRatios(1)+VerySmall)+1;
if Rank2==Rank3
    vOptNuAfterD=vOptNuBeforeD;
    vOptMuAfterD=vOptMuBeforeD;
else
    error('Something wrong!! Possible numerical error.....')
end

f1=figure;
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataBeforeD(:,1),DataBeforeD(:,2),DataBeforeD(:,3),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',0.2);
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

f2=figure;
hold on
view(45,25)
scatter3(DataShare(:,1),DataShare(:,2),DataShare(:,3),'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],'LineWidth',0.2);
scatter3(DataDMUo(1),DataDMUo(2),DataDMUo(3),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',0.2);
scatter3(DataAfterD(:,1),DataAfterD(:,2),DataAfterD(:,3),'k','LineWidth',0.2);
xlabel('Input1')
ylabel('Input2')
zlabel('Output')
axis([x1Lower x1Upper x2Lower x2Upper 0 max(mOutput)]);
xLim = [x1Lower,x1Upper];
yLim = [x2Lower,x2Upper];
[X,Y] = meshgrid(xLim,yLim);
ratio=(OrgData(iDMUo,3)*vOptMuAfterD)/(OrgData(iDMUo,1:2)*vOptNuAfterD);
Z=ratio*(vOptNuAfterD(1)*X+vOptNuAfterD(2)*Y)/vOptMuAfterD;
reOrder = [1 2  4 3];
patch(X(reOrder),Y(reOrder),Z(reOrder),'c');
alpha(1);
%-----TechRank  End---------------------------------------------------
set(f1,'Position',[100 100 500 400])
set(f2,'Position',[100 100 500 400])
set(f3,'Position',[100 100 500 400])
set(f4,'Position',[100 100 500 400])
set(f5,'Position',[100 100 500 400])
set(f6,'Position',[100 100 500 400])

saveas(f1,'TechRank1.eps','epsc');
saveas(f2,'TechRank2.eps','epsc');
saveas(f3,'EcoRank1.eps','epsc');
saveas(f4,'EcoRank2.eps','epsc');
saveas(f5,'EcoBuffRank1.eps','epsc');
saveas(f6,'EcoBuffRank2.eps','epsc');
close all













