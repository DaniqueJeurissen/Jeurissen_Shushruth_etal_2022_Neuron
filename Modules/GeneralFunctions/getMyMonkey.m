function monkey = getMyMonkey(monkeyID)
% based on monkey number, get the monkey's name to load the data

if monkeyID == 1
    monkey = 'Napoleon';
elseif monkeyID == 2
    monkey = 'Damien';
elseif monkeyID == 3
    monkey = 'Yossarian';
elseif monkeyID == 4
    monkey = 'Megatron';
else
    warning('Define monkeyID between 1 and 4')
end