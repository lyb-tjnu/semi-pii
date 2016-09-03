% pc2im - Point cloud to perspective intensity images.
%         Given a point cloud, this script generates a series of 
%         perspective intensity images of the scanning scene.
%
% Input:
%   A point cloud.
%
% sample lines of the point cloud file s1.off:
% -0 -0.003 0.933 225
% -0 -0.003 0.932 227
% -0 -0.003 0.932 225
% ... ...
%
% Each line records the xyz coordinates and the intensity value of a point.
%
% Outputs:
%   A series of perspective intensity images saved as .jpg files, which are named sequentially.
%   A series of index matrices saved as .mat files, which record indices of the 3D points
%   that correspond to pixels of the corresponding intensity images.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
data = dlmread('s1.off',' ',0,0);
npts = size(data,1);
XYZ = data(:,1:3);
XYZ = XYZ';
INTENSITY = data(:,4); 
INTENSITY = INTENSITY';

fprintf('%d points read\n', npts);
asr = 3/4; % aspect ratio
f=10/1000; % focal length in meters
pixSize = 0.00001; % pixel size
% sensor dimension
sensorW = 0.02048; sensorH = sensorW*asr;
% image dimension
imW = uint32(sensorW/pixSize); imH = uint32(imW*asr); 
% principal point location
colPP = double(imW/2); rowPP = double(imH/2); 

Xs=0; Ys=0; Zs=0;
cp = [Xs Ys Zs]'; % projection center
phi=-pi/2;
omega=0;
kappa=-pi/2;
R = angle2rm(phi,omega,kappa);
dAngle = 30*pi/180;
angle = 0;
m = 1;

bkg = min(INTENSITY)-100; % background color

while(angle < 2*pi)	
	tic

	image = bkg*ones(imH,imW); % image initialized with dark background
	distmat = 100*ones(imH,imW); % minimum range initialized to 100m
	indmat = zeros(imH,imW); % index matrix of 3D points corresponding to pixels

	% three corners of image plane
	uright = [f -sensorW/2 sensorH/2]'; 
	lleft = [f sensorW/2 -sensorH/2]';
	lright = [f -sensorW/2 -sensorH/2]';

    R1 = angle2rm(0,0,angle);
	
	p = R1 * XYZ; % p is 3 by n

	a2 = lright - lleft;
	a3 = uright - lleft;
	b = (cp-lleft);

	repcp = repmat(cp,1,npts);
	p1 = R*(p-repcp); % p1 is 3 by n

	x = -f*p1(1,:)./p1(3,:); % x is 1 by n
	y = -f*p1(2,:)./p1(3,:); % y is 1 by n

	% matlab image coordiante direction?
	row = int32(rowPP - y/pixSize);
	col = int32(colPP - x/pixSize); % ?

	for(i=1:npts)	
		% projection center and P lie on different side of image plane
		a1 = cp - p(:,i);
		A = [a1 a2 a3];

		t = A\b; 

		if(t(1)>=0 && t(1)<=1)
			if(1<=row(i) && row(i) <= imH && 1<=col(i) && col(i) <= imW) % projection of the point is within the range of an image
				dist = norm(XYZ(:,i));
				% point is nearest to the center of projection
				if( dist < distmat(row(i),col(i)))
					image(row(i),col(i)) = INTENSITY(i);
					distmat(row(i),col(i)) = dist;
					indmat(row(i),col(i)) = i;
			    end
	    	end
    	end
    end

	%  nearest neighbor interpolation
	image_itp = image;
	for s = 2 : imH-1 % not 1:imH
		for t = 2 : imW-1 % not 1:imW
			if(image(s,t) == bkg)
				intvec = [image(s-1,t) image(s,t+1) image(s+1,t) image(s,t-1) image(s-1,t-1) image(s-1,t+1) image(s+1,t+1) image(s+1,t-1)];
				q = 1;
				while(q < 9)
					if(intvec(q) ~= bkg)
						image_itp(s,t) = intvec(q);
						break;
					end
					q = q+1;					
				end
			end
		end
	end

    I2 = mat2gray(image_itp); % converts the matrix to an intensity image whose value is within the range [0,1]
	% 	gamma correction
	I3 = (I2).^(2.2);
	I3 = im2uint8(I3); % transform gray values in range [0~255]
	% rescale
	I4 = imadjust(I3, stretchlim(I3));
	imgfilename = strcat(int2str(m),'.jpg'); 
	imwrite(I4,imgfilename,'jpg');

	indmat = uint32(indmat);
	indfilename = strcat(int2str(m),'.mat'); 
	save(indfilename,'indmat');

	angle = angle + dAngle;
	m = m + 1;

	toc
end
