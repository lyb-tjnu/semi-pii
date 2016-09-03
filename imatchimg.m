% imatchimg - Interactively match intensity images and register point clouds.
%         Given point clouds to be registered, perspective intensity images and index matrices,
%         this script can be used to interactively match intensity images and register point clouds.
%
% Inputs:
%   Two point clouds to be registered.
%   Perspective intensity images and index matrices generated from these point clouds.
%
% Outputs:
%   Transformation parameters: rotation matrix R and translation vector t
%   Residuals along xyz axis: resx, resy, resz
%   RMSE along xyz axis: stdx, stdy, stdz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
% input perspective intensity images
I1 = imread('s1_1.jpg');
I2 = imread('s2_3.jpg');
I3 = imread('s1_4.jpg');
I4 = imread('s2_4.jpg');
I5 = imread('s1_9.jpg');
I6 = imread('s2_10.jpg');

% extract corners
imagePoints1 = detectMinEigenFeatures(I1);
imagePoints2 = detectMinEigenFeatures(I2);
imagePoints3 = detectMinEigenFeatures(I3);
imagePoints4 = detectMinEigenFeatures(I4);
imagePoints5 = detectMinEigenFeatures(I5);
imagePoints6 = detectMinEigenFeatures(I6);

figure; imshow(I1); hold on; plot(imagePoints1);
figure; imshow(I2); hold on; plot(imagePoints2);
figure; imshow(I3); hold on; plot(imagePoints3);
figure; imshow(I4); hold on; plot(imagePoints4);
figure; imshow(I5); hold on; plot(imagePoints5);
figure; imshow(I6); hold on; plot(imagePoints6);

% interactively select tie points in intensity images
pos_s1_1 = [1768 602.7;1261 526.8;];
pos_s2_3 = [947.6 731.9;859 720;];

pos_s1_4 = [330.7 599;285.5 922.4;1836 702.9;364.8 979.2;];
pos_s2_4  = [1009 749;1003 797.8;1229 764;1015 805.9;];

pos_s1_9  = [828 744;756.3 758;969.7 774.2;666.3 726.7;];
pos_s2_10  = [1169 634.1;746.5 702.2;1968 800.6;81.51 487.2;];

% switch x and y coordinates
pos_s1_1 = uint16([pos_s1_1(:,2) pos_s1_1(:,1)]);
pos_s2_3 = uint16([pos_s2_3(:,2) pos_s2_3(:,1)]);
pos_s1_4 = uint16([pos_s1_4(:,2) pos_s1_4(:,1)]);
pos_s2_4 = uint16([pos_s2_4(:,2) pos_s2_4(:,1)]);
pos_s1_9 = uint16([pos_s1_9(:,2) pos_s1_9(:,1)]);
pos_s2_10 = uint16([pos_s2_10(:,2) pos_s2_10(:,1)]);

data = dlmread('s1.off',' ',0,0); s1 = data(:,1:3);
data = dlmread('s2.off',' ',0,0); s2 = data(:,1:3);

Xs1 = zeros(3,13); Xs2 = zeros(3,13);

m = 0; % number of valid pair of tie points
ntiepts = size(pos_s1_1, 1);
for i=1:ntiepts 
	index1 = getindex(indmats1_1, pos_s1_1(i,1), pos_s1_1(i,2));
	index2 = getindex(indmats2_3, pos_s2_3(i,1), pos_s2_3(i,2));
	if(index1 ~= 0 && index2 ~=0)
		m = m + 1;
		Xs1(:,m) = s1(index1,1:3)';
		Xs2(:,m) = s2(index2,1:3)';		
	end
end

ntiepts = size(pos_s1_4, 1);
for i=1:ntiepts
	index1 = getindex(indmats1_4, pos_s1_4(i,1), pos_s1_4(i,2));
	index2 = getindex(indmats2_4, pos_s2_4(i,1), pos_s2_4(i,2));
	if(index1 ~= 0 && index2 ~=0)
		m = m + 1;
		Xs1(:,m) = s1(index1,1:3)';
		Xs2(:,m) = s2(index2,1:3)';
	end
end

ntiepts = size(pos_s1_9, 1);
for i=1:ntiepts
	index1 = getindex(indmats1_9, pos_s1_9(i,1), pos_s1_9(i,2));
	index2 = getindex(indmats2_10, pos_s2_10(i,1), pos_s2_10(i,2));
	if(index1 ~= 0 && index2 ~=0)
		m = m + 1;
		Xs1(:,m) = s1(index1,1:3)';
		Xs2(:,m) = s2(index2,1:3)';
	end
end

Xs1 = Xs1(:,1:m);
Xs2 = Xs2(:,1:m);

[R, t, resx, resy, resz, stdx, stdy, stdz] = regsac(Xs1, Xs2, m, 22, 0.01);
