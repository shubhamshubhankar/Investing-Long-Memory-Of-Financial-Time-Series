clc; clearvars; close all;
%% download prices
%const={'DX=F','6E=F','EUR=X','EURUSD=X'}; % ex future and spot exchange rate

T = readtable('Sp500Components.xlsx');
const = T.Symbol;
pesi=T.Weight;
pesi(1:14)=pesi(1:14)./(10.^floor(log10(abs(pesi(1:14))+1))-1); %correction
Prezzi=Scarico(const,5000);

