function factors = calcQuantitiesMultipliersToConformWeights(quants, weights)
    if numel(quants)~=numel(weights)
        error('number of elements in quants must equal number of elements in weight');
    end      
        
    factors = NaN(1, numel(quants));
    factors(1) = weights(1);
    for i = 2:numel(quants)
        factors(1) = lcm(factors(1),quants(i)/gcd(quants(1)*weights(i), quants(i)*weights(1)));
    end
    
    for i = 2:numel(quants)
        factors(i) = factors(1) * quants(1)*weights(i)/(quants(i)*weights(1));
    end
end