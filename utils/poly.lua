require "utils.matrix1"
require "utils.class.class"

Poly1d = class()

function Poly1d:init(coeffs)
	self.coeffs = coeffs
end

-- Utility function for computing a polynomial with a single variable.
-- coeffs: list of coefficients, highest order terms first. (x^2 + x + 1.. - in that order)
-- X: a Matrix object, or a single number.
-- TODO: for higher degree linear regression, need N dimensional polynomial??
function Poly1d:compute(X)
	local compute_entry = function(x)
		local sum = 0
		for i=1,#self.coeffs-1 do
			sum = sum + self.coeffs[i]*math.pow(x,#self.coeffs-i)
		end
		sum = sum + self.coeffs[#self.coeffs]
		return sum
	end
	return X:map(compute_entry)
end

-- Utility class for computing linear expressions of N independent variables
-- Name means "Multivariate linear expression"
-- Expression like thet_1*x_1 + thet_2*x_2 + ...
MultiLinearExpr = class()

-- Initialize the multivariate linear expression.
-- N - int indicating how many independent variables will be present in the polynomial.
-- params - a list of parameters for the object. Give in order (x_3 + x_2 + x_1 + 1)  - intercept term at end
function MultiLinearExpr:init(num_independent_vars, params)
	assert(#params == num_independent_vars+1, "not enough params")
	self.num_independent_vars = num_independent_vars
	self.params = params
end

-- Compute the multivariate polynomial.
-- X: is a Matrix object, having at least N columns, and any amount of rows.
function MultiLinearExpr:compute(X)
	assert(X:shape()[2] == self.num_independent_vars, "Dimension mismatch (required amount of columns not met)")

	-- Need to insert a column of ones for the intercept term.
	X_array = X:copy()
	local ones_array = Matrix:ones(X_array:shape()[1],1)
	X_array:insert(1,ones_array.table)
	--print(X_array:to_string())
	params_vector = Matrix:new({self.params})
	params_vector = params_vector:transpose()
	--print(params_vector:to_string())
	return X_array:mat_mul(params_vector)
end

-- Adds polynomial features to a given input matrix.
-- Intended to be called "statically"
-- TODO: function MultiLinearExpr:poly_features()
