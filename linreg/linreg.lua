-- NOTES:
-- OOP approach. like scikit learn
-- might require polynomial convenience functions
-- implement batch and stochastic gradient descent
-- TODO: make robust enough for MLR
-- TODO: object oriented approach
-- TODO: batch vs stochastic gradient descent


require "utils.matrix1"
require "utils.class.class"
require "utils.poly"

-- params: a vector of n coefficients for the regression terms
-- X: [x1, x2, x3..] - Matrix object. 1 by n preferred
-- Y: a
function cost_func(params,X,Y)
	-- Ensure same shape
	assert((X:shape()[1] == Y:shape()[1]) and (X:shape()[2] == Y:shape()[2]), "X and y not same shape")
	-- Compute error
	fit_func = Poly1d(params)
	y_hat = fit_func:compute(X)

	abs_error = Y:subtract(y_hat)

	-- Compute cost

	-- Square every element, divide by two.
	result = abs_error:map(function(x) return (.5)*math.pow(x,2) end)
	-- Sum along rows
	result = result:sum(0)
	-- Divide by # of points
	N = X:shape()[2]
	result = result:scalar_mult(1/N)
	-- TODO: more robust here???
	return result.table[1][1]

end
function gradient(params,X,Y)
	fit_func = Poly1d(params)
	y_hat = fit_func:compute(X)

	abs_error = y_hat:subtract(Y)
	print("abs error")
	print(abs_error:to_string())
	-- Prepend 1s before X
	X_array = X:copy()
	ones = Matrix:ones(1,X:shape()[2])
	-- Doesn't return in right order, so to reverse...?
	X_array:insert(0,ones.table)
	print("X array")
	print(X_array:to_string())

	result = X_array:mat_mul(abs_error:transpose())
	N = X:shape()[2]
	result = result:scalar_mult(1/N)
	print(result:to_string())
	return result
end

-- Test

-- Parameters
test = Poly1d({1,2})
-- Data
--X = Matrix({{1,5,3,6,2,3,2,6}})
--Y = Matrix({{1,3,6,3,2,7,3,6}})


X = Matrix({{1,2,3,4,5,6}})
Y = Matrix({{1,2,3,4,5,6}})

alpha = 0.1
epsilon = alpha*math.pow(10,-10)

last_cost = 0
current_cost = cost_func(test.coeffs,X,Y)
print(current_cost)
this_gradient = gradient(test.coeffs,X,Y)
print(this_gradient:to_string())

while (math.abs(current_cost-last_cost) > epsilon) do
	this_gradient = gradient(test.coeffs,X,Y)
	for i,grad in ipairs(this_gradient.table) do
		-- Update weights
		-- print(test.coeffs[i])
		-- print(this_gradient.table[i])
		test.coeffs[i] = test.coeffs[i] - alpha*this_gradient.table[i][1]
	end
	last_cost = current_cost
	current_cost = cost_func(test.coeffs,X,Y)

	print("testcoeefs" .. test.coeffs[1] .. "," .. test.coeffs[2])
end
print(test.coeffs)
