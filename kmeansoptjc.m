function [IDXs,sCl,M,S] = kmeansopt(E,N,type)

%E p parameters (cells) by N Events
%N number of trials per cluster number
%p p-value for cluster validation

Ne = size(E,2);

%% Covariance matrix
if strcmp(type,'var')
    M = CovarM(E);
end

%% k-means loop
%
% tic
% parfor k = 1:N*18
%     NCl = floor((k-1)/N) + 2;
% %     IDX = kmeans(E',NCl)'; %Normal K-means on distance metric
%     IDX = kmeans(M,NCl);    % Kmeans on distance of covariance metric
%     s = silh(M,IDX);
%     IDX0(k,:) = IDX;
%     S(k) = mean(s);
% end
% toc
stream = RandStream('mlfg6331_64');  % Random number stream
options = statset('UseParallel',1,'UseSubstreams',1, 'Streams',stream);
for k = 2:20
    [IDX,~,sumD]  = kmeans(M,k,'Replicates',100,'Options',options,"MaxIter",300,'OnlinePhase','on'); 
    sumDk{k}=sumD;
    s=silhouette(M,IDX);
    IDX0(k,:) = IDX;
     S(k) = mean(s);
end
toc


%Best clustering for each cluster number

% IDX1 = zeros(18,Ne);
% for i = 1:18
%     tmp = IDX0((i-1)*N+(1:N),:);
%     [~,idx] = max(S((i-1)*N+(1:N)));
%     IDX1(i,:) = tmp(idx,:);
% end

%% keep best silhouette

% [~,ClOK] = max(S);
% NCl = floor((ClOK-1)/N) + 2;
[~ , NCl] = max(S);
IDX = IDX0(NCl,:);
s = silhouette(M,IDX);
sCl = zeros(1,NCl);
for i = 1:NCl
    sCl(i) = median(s(IDX==i));
    % sCl(i) = median(s(IDX==i));
end

%sort RACE/silhouette of best cluster
[sCl,xCl] = sort(sCl,'descend');
IDXs = zeros(1,Ne);
for i = 1:NCl
    IDXs = IDXs + (IDX == xCl(i))*i;
end
