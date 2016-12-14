%% Battleships / Schiffe versenken
% 1 = ships
% 2 = neighbouring squares
% 8 = miss
% 9 = hit

% player's view:
% 1 = hit
% 5 = miss
clear; clc; global N

% switches
show_initial_placement = 1; %solution
show_board = 0; % 0=No, 1=Player's view, 2=Full view
show_comments = 1; % 0=No, 1=Some, 2=all
makepause = 0; % make a pause after each move (continue with any key)

% choose strategy
str=randperm(N^2)'; %random strategy(choosing moves without replacement)

N=10; %number of rows/columns on board
fleet=[4 3 3 2 2 2 1 1 1 1];

%% place the ships
myboard=zeros(N^2,1); myboardv=myboard;
for shipsize=fleet

    % determine valid ship position
    r = 0; ship=[]; iship=0; 
    while mod(r-1,N)> mod(r-1+shipsize,N) || any(myboard(ship))~=0
        % condition: when ship jumps over the edge, or is on inpermissible
        % square, the rng keeps running
        r = randi(N^2-shipsize+1,1);
        ship=r:r+shipsize-1;
        iship=iship+1;
        if iship>100  %changes from vertical to horizontal, if other is (nearly) impossible
            myboard=myboard';
        end
        if iship>100000  % breakout condition
            error('could not find a place for the ship')
        end
    end
myboard(ship)=1; % position the ship

% fill neighbouring squares (clockwise, starting top left)
neigh = neighbours(ship);
if any(myboard(neigh)~=0 &  myboard(neigh)~=2)
    error('ship placement is not allowed')
end
myboard(neigh)=2;
clear neigh % precaution

if randn(1)<0 %turn board 50% of times
        myboardm = reshape(myboard,[N, N]);
        myboardm = myboardm';
        myboard = myboardm(:);
end
end
if show_initial_placement
    disp('boat positions:')
    myboardinit=reshape(myboard==1,[N,N]) % original board
end
%% strategy

es=str; % effective strategy, can change

% initialization
logbook=zeros(N^2,3);
logbook(:,1)=str;
remships=length(fleet);
tries=1; huntermode=0; hunterpos=[];


%% play

for j=1:100; %length(s)+25
    %[j s(j) huntermode]
    if huntermode
        % if in huntermode, I change strategy to choose neighbouring square
        % of the last hit
        hcand = neighbours(hunterpos, 1,1); % hunter candidate is neighbour
        hcand = hcand(~ismember(hcand, es(1:j-1))); % hunter candidate has not been played
        hvalue = hcand(randi(length(hcand))); % hunter value chosen randomly
        % change effective strategy
        elast=es(j:end);
        es=[es(1:j-1); hvalue; elast(elast~=hvalue)];
        % doublecheck
        assert(es(j)==hvalue);
        assert(length(es)==N^2)
    end
    
    %check validity of hit
    assert((es(j)>=0) && (es(j)<=N^2)) % hit in range
    if myboard(es(j))==9 || myboard(es(j))==8 % hit already taken
        if show_comments
            disp([num2str(es(j)) ' is an invalid move'])
        end
        logbook(j,2:3)=[es(j) -1];
        continue
    end
    
    % the effective play is es(j)
    
    if huntermode %log the hits taken in huntermode as a negative
        logbook(j,2)=-es(j);
    else
        logbook(j,2)=es(j);
    end
    if show_comments==2
        disp(['try ', num2str(tries), '. you play ', num2str(es(j))])
    end
    
    %success
    if myboard(es(j))==1;
        if show_comments
            disp('you hit a ship!!!')
        end
        myboard(es(j))=9;
        myboardv(es(j))=1;
        logbook(j,3)=1;
        
        [sunkship, sunk] = shipsunk(es(j), myboard);
        if sunk==1 % when the ship sank:
            %uncover the neighbouring squares
            neigh = neighbours(sunkship);
            myboard(neigh)=8;
            myboardv(neigh)=5;
            
            remships=remships-1;
            if show_comments
                disp(['ship sunk! ', num2str(remships), ' ships remaining'])
            end
            if remships==0 % 1) check if game won
                disp(['you won. game terminated after ' num2str(tries) ' tries'])
            break
            end
            if huntermode % 2) if no win, leave hunter mode
                huntermode=0; hunterpos=[];
            end
        else
            huntermode = 1;
            hunterpos=[hunterpos; es(j)];
            if show_comments==2
                disp('huntermode!')
            end
        end
        
    %no hit
    elseif myboard(es(j))==0 || myboard(es(j))==2
        myboard(es(j))=8;
        myboardv(es(j))=5;
        logbook(j,3)=8;
        tries=tries+1;
        if show_comments
            disp('no hit')
        end
    else 
        error(['invalid number in square ' num2str(es(j))]) 
        
    end
    if show_board == 1
        myboardmv=reshape(myboardv,[N,N])
    elseif show_board ==2
        myboardm=reshape(myboard,[N,N])
    end
    if makepause
        pause
    end
end

  %%
checksum=sum(logbook(:,3)==1);
assert(checksum==20)
%myboardmv=reshape(myboard,[N,N])
    