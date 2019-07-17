function A = fillin_diag(A, d, val)

% d = diagonal you want to fill up; 0 is the main diagonal; positive is upper and negative is lower diag
% val = the value you want to have at the diagonal
% A = your matrix

if abs(d) >= max(size(A))
    error('out of size');
end

s = size(diag(A, d), 1) + abs(diff(size(A)));
B = diag(ones(1, s) * val, d); 
B = B(1 : size(A, 1) , 1 : size(A, 2));
A = A + B;
end