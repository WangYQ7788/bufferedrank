clc
clear

mInput=xlsread('pigdata.xlsx','input')/10^4;
mOutput=xlsread('pigdata.xlsx','output')/10^4;

[J,nInput]=size(mInput);
[JOutput,nOutput]=size(mOutput);
if J~=JOutput
    error('The input and output matrix must have the same num of rows');
end

params.IntFeasTol=1e-9;
params.MIPGap=0;
params.MIPGapAbs=0;
params.TimeLimit=600;
params.MIPFocus=2;

for iDMUo=1:J
    %best buffered-ranking of economic efficiency
    [BestBuffRank,RunTime,UpperRankOfBuffRank]=BestEcoBuffRankFun(mInput,mOutput,iDMUo,params);
    mRunTime(iDMUo,3)=RunTime;
    mRank(iDMUo,2)=UpperRankOfBuffRank;
    mRank(iDMUo,3)=BestBuffRank; 
    
    %worst buffered-ranking of economic efficiency
    [WorstBuffRank,RunTime,LowerRankOfBuffRank]=WorstEcoBuffRankFun(mInput,mOutput,iDMUo,params);
    mRunTime(iDMUo,4)=RunTime;
    mRank(iDMUo,4)=WorstBuffRank;
    mRank(iDMUo,5)=LowerRankOfBuffRank;

    %best ranking of technical efficiency
    [Rank,RunTime]=BestTechRankOpt(mInput,mOutput,iDMUo,params);
    mRunTime(iDMUo,5)=RunTime;
    mRank(iDMUo,7)=Rank; 
    
    %worst ranking of technical efficiency
    [Rank,RunTime]=WorstTechRankOpt(mInput,mOutput,iDMUo,params);
    mRunTime(iDMUo,6)=RunTime;
    mRank(iDMUo,8)=Rank;
    
    %best ranking of economic efficiency
    [BestRank,RunTime]=BestEcoRankOpt(mInput,mOutput,iDMUo,params);
    mRunTime(iDMUo,1)=RunTime;
    mRank(iDMUo,1)=BestRank; 
    
    %worst ranking of economic efficiency
    [WorstRank,RunTime]=WorstEcoRankOpt(mInput,mOutput,iDMUo,params);
    mRunTime(iDMUo,2)=RunTime;
    mRank(iDMUo,6)=WorstRank;  
 end
mRank
mRunTime
save pig

%     cvx_begin
%         variable dBeta(J) nonnegative
%         variable dNu(nInput) nonnegative
%         variable dMu(nOutput) nonnegative
%         minimize(sum(dBeta))
%         subject to
%             mOutput*dMu-mInput*dNu-vOutput*dMu+vInput*dNu+1<=dBeta;
%     cvx_end
%     if strcmp(cvx_status,'Solved')
%         vBestBuffRank(iDMUo,1)=cvx_optval;
%     else
%         error('Fail to obtain the optimum.')
%     end
%     vBestBuffRankCVX(iDMUo,1)=cvx_optval;

    %[xout, fval, status, output] = riskprog('bPOE',w,H,c,p,d,A,b,Aeq,beq,lb,ub);
    %mpsg_problem_exporttotext(problem_statement_1, iargstruc_1, '.');  % for export problem into txt format
 


