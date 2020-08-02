function [Rank,RunTime,ApproxRank]=WorstEcoBuffRankFun(mInput,mOutput,iDMUo,params)
%Aim
%Estimate the best buffered ranking of the economic efficiency of iDMUo among DMUs (mInput,mOutput)

%inputs
%mInput: matrix of inputs, x_jm, row: DMU, column: input
%mOutput:matrix of outputs, x_jn, row: DMU, column: output
%jDMUo: a number, the DMU to be evaluated
%params: the gurobi parameters

%output
%Rank: number, the Worst rank for DMUo
%RunTime: time in seconds, running time for computing DMUo's Worst ranking
%ApproxRank: the upper rank of DMUo in J measures E_j(nu*,mu*)

[J,nInput]=size(mInput);
[J1,nOutput]=size(mOutput);
BigC=0;
for m=1:nOutput
    if mOutput(iDMUo,m)~=0
        BigC=max(BigC,max(mOutput(:,m)/mOutput(iDMUo,m)));
    end
end

model.obj=[ones(J,1);zeros(nInput+nOutput,1)];
model.lb=zeros(J+nInput+nOutput,1);
model.ub=Inf*ones(J+nInput+nOutput,1);
model.A=sparse([-eye(J),mInput-ones(J,1)*mInput(iDMUo,:),-mOutput+ones(J,1)*mOutput(iDMUo,:)]);
model.rhs=-ones(J,1);
model.sense=repmat('<',J,1);
model.modelsense ='min';
model.objcon=0;
model.vtype=repmat('C',J+nInput+nOutput,1); 

results = gurobi(model,params);
RunTime=results.runtime;
Rank=J+1-results.objval;
vOptNu=results.x((J+1):(J+nInput));
vOptMu=results.x((J+1+nInput):end);
vEffScore=mOutput*vOptMu-mInput*vOptNu;
ApproxRank=sum(vEffScore>=vEffScore(iDMUo));
