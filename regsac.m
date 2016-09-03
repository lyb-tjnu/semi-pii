% regsac is short for point cloud registration using RANSAC
% R: ratation matrix
% t: translation vector
% X1: 3D coordinates of tie points from point cloud 1 
% X2: 3D coordinates of tie points from point cloud 2
% nmatches: number of matches
% nsamp: number of samples
% T: inlier threshold

function [R, t, resx, resy, resz, stdx, stdy, stdz] = regsac(X1, X2, nmatches, nsamp, T)
nmax = 0;
inliers = zeros(nmatches,1);

for(i = 1:nsamp)
    choice = randperm(nmatches);
    TX1 = X1(:, choice(1:3));
	TX2 = X2(:, choice(1:3));   
    
    [c, TR, Tt] = ralign(TX1, TX2);
    
	Tinliers = zeros(nmatches,1);
	Tinliers(1:3) = choice(1:3);
	n = 0;

    for j = 4:nmatches
        if(norm(TR*X1(:,choice(j))+Tt - X2(:,choice(j))) < T) 
			n = n + 1;
			Tinliers(j) = choice(j);
		end
    end

	if(n > nmax)
		nmax = n;
		inliers = Tinliers;
	end
end

inliers = inliers(inliers > 0);
FX1 = X1(:, inliers);   
FX2 = X2(:, inliers);   
[c, R, t] = ralign(FX1, FX2);

% residual
resmax = zeros(size(FX2));
for j = 1:size(FX2,2)
	resmax(:,j) = R*FX1(:,j) + t - FX2(:,j);
end
resx = resmax(1,:);
resy = resmax(2,:);
resz = resmax(3,:);

% std
stdx = sqrt((resx * resx')/length(resx));
stdy = sqrt((resy * resy')/length(resy));
stdz = sqrt((resz * resz')/length(resz));
