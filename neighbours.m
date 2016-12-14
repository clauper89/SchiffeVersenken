function [neigh] = neighbours(position, crossonly, hunter)
global N

if isempty(position)
    error('not enough input in neighbours function')
end
if nargin==1
    crossonly=0;
    hunter=0;
elseif nargin==2
    hunter=0;
end

neigh=[];
for i=1:length(position)
    
left = position(i)-N;
dleft=position(i)-N+1; 
uleft=position(i)-N-1;
right = position(i)+N; 
dright=position(i)+N+1; 
uright=position(i)+N-1;
upp = position(i)-1; 
downn=position(i)+1;

nodown=mod(position(i),N)==0;
noleft=position(i)<=N;
noright=position(i)>N^2-N;
noup=mod(position(i),N)==1;


    if ~noup
       if ~crossonly && ~noleft
           neigh=[neigh; uleft]; %uleft
       end
       neigh=[neigh; upp]; %up
       if ~crossonly && ~noright
           neigh=[neigh; uright]; %uright 
       end
   end
   if  ~noright 
       neigh=[neigh; right];
   end
   if ~nodown
       if ~crossonly && ~noright
           neigh=[neigh; dright]; %dright 
       end
       neigh=[neigh; downn]; %down
       if ~crossonly && ~noleft
          neigh=[neigh; dleft]; %dleft
       end
   end
   if ~noleft
       neigh=[neigh; left];
   end
end
%neigh=unique(neigh);
neigh=sort(neigh);
difference=[1; diff(neigh)];
neigh=neigh(difference~=0);

neigh(ismember(neigh,position))=[];

if hunter && length(position)>1
  difference=position(2)-position(1);
  for i=1:length(neigh)
      if all(position-difference~=neigh(i)) && all(position+difference~=neigh(i))
          neigh(i)=0;
      end
  end
  neigh=neigh(neigh~=0);
end

end

