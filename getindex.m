function index = getindex(indmat,s,t)
index = indmat(s,t);
if(index == 0)
	vec = [indmat(s-1,t) indmat(s,t+1) indmat(s+1,t) indmat(s,t-1) indmat(s-1,t-1) indmat(s-1,t+1) indmat(s+1,t+1) indmat(s+1,t-1)];
	q = 1;
	while(q < 9)
		if(vec(q) ~= 0)
			index = vec(q);
			break;
		end
		q = q+1;					
	end
end

