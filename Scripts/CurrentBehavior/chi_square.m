function [chi_square_value, p_value] = chi_square(observedFreq, expectedFreq, df)
    chi_square_value = sum((observedFreq-expectedFreq).^2 ./ expectedFreq);
    p_value = 1 - chi2cdf(chi_square_value, df);
end

