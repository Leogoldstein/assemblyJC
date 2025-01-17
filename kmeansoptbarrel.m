function [IDXs,sCl,M,S] = kmeansoptbarrel(E,N,type,NCl)

%E p parameters (cells) by N Events
%N number of trials per cluster number
%p p-value for cluster validation

Ne = size(E,2);

%% Covariance matrix
if strcmp(type,'var')
    M = CovarM(E);
end

%% k-means loop
% rng("default")
% NCl=15;
parfor k = 1:N
    % NCl = floor((k-1)/N) + 2;
    % IDX = kmeans(E',NCl)'; %Normal K-means on distance metric
    IDX = kmeans(M,NCl,"MaxIter",300,'OnlinePhase','on');%,'distance','cityblock');    % Kmeans on distance of covariance metric
    s = silh(M,IDX);
    IDX0(k,:) = IDX;
    S(k) = median(s);
end


[~,ClOK] = max(S); 
% test = prctile(S,95); 

IDX = IDX0(ClOK,:);
s = silh(M,IDX);
sCl = zeros(1,NCl);
for i = 1:NCl
    % sCl(i) = median(s(IDX==i));
    sCl(i) = mean(s(IDX==i));
end

%sort RACE/silhouette of best cluster
[sCl,xCl] = sort(sCl,'descend');
IDXs = zeros(1,Ne);
for i = 1:NCl
    IDXs = IDXs + (IDX == xCl(i))*i;
end

