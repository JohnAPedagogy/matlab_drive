function parameter = initializeZeros(sz)

weights = zeros(sz,'single');
parameter = dlarray(weights);

end