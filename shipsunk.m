function  [ship, sunk] = shipsunk(hit, myboard)
%shipsunk check if ship has sunk. If so, find the position of the ship

%find intact square in immediate vicinity
neigh = neighbours(hit,1,1);
if any(myboard(neigh)==1)
    ship=[]; sunk=0; neigh=[];
    return
end

% find the whole part of the ship which has been sunk
ship=hit; cand=-1;
while ~isempty(cand)
neigh = neighbours(ship,1,1);
cand=neigh(myboard(neigh)==9);
ship = [ship; cand];
end

% look for intact squares in vicinity of the whole ship
if all(myboard(neigh)~=1)
    sunk=1;
elseif any(myboard(neigh)==1)
    sunk=0; ship=[]; neigh=[];
else
    error('error in shipsunk function. cannot determine if ship sunk')
end

end

