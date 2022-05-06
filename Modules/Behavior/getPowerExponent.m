function pow_rdm = getPowerExponent
% For stimulus strength in the rdm task, we use the coherences times the 
% dot duration to the power of an exponent. This exponent is different for 
% the two monkeys (fit to the data).
% This function returns the exponent for each monkey. 

pw_monkey1 = 0.38;
pw_monkey2 = 0.43;

pow_rdm = [pw_monkey1 pw_monkey2];
