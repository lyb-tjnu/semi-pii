function IA = fillimg(I,indmat)
IA = I;
nei = zeros(1,8);
for i = 1:size(I,1)
	for j = 1:size(I,2)
		nei = [I(i,j+1) I(i-1,j+1) I(i-1,j) I(i-1,j-1) I(i,j-1) I(i+1,j-1) I(i+1,j) I(i+1,j+1)];
		[gv,ind] = max(nei);
	    IA(i,j) = gv;
		indmat = 
	end
end


