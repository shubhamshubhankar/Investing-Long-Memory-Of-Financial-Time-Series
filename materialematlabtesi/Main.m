clc;close all;clearvars;
%% load price
load prezzi.mat
Ticker=string(Prezzi.Properties.VariableNames);
Ticker=Ticker(3:end-1);
Valori=table2array(Prezzi(:,3:end));
Valori=str2double(Valori)/100;
Ret=diff(log(Valori));
Ret=Ret(:,1:end-1);
%% param
InS=7*10;
OutS=7*2;
%% contenitori
StratOnlyRet=[];
StratOnlyH=[];
StratDouble=[];
%% main loop
for t=InS:OutS:size(Ret)
    % leggo in and out
    DatiIn=Ret(t-InS+1:t,:);
    DatiOut=Ret(t+1:t+OutS,:);
    % do return in
    RetIn=sum(DatiIn);
    % do hurst in
    H=zeros(size(RetIn));
    for j=1:size(DatiIn,2)
        H(j)=RS(DatiIn(:,j),0);
    end
    % sorting
    [~,Posret] = sort(RetIn);
    [~,PosH] = sort(H);
    % top bott ret
    topRet=Posret(1:252);
    botRet=Posret(253:end);
    % top bott H
    topH=PosH(1:252);
    botH=PosH(253:end);
    % strat ret
    t1=mean(sum(DatiOut(:,topRet)));
    b1=mean(sum(-DatiOut(:,botRet)));
    StratOnlyRet=[StratOnlyRet,(t1+b1)/2];
    % strat H
    t1=mean(sum(DatiOut(:,topH)));
    b1=mean(sum(-DatiOut(:,botH)));
    StratOnlyH=[StratOnlyH,(t1+b1)/2];
    % strat double
    top2=intersect(topRet,topH);
    bot2=setdiff(1:size(PosH,2),top2);
    t1=mean(sum(DatiOut(:,top2)));
    b1=mean(sum(-DatiOut(:,bot2)));
    StratDouble=[StratDouble,(t1+b1)/2];

end