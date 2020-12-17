require "utils.class.class"
require "utils.matrix1"
require "utils.poly"

-- TODO: this whole thing...

LinearRegression = class()

-- TODO: initialization parameters should include
-- alpha, epsilon, batch vs stochastic
function LinearRegression:init(num_independent_vars)
  -- Randomly initialize the starting parameters.
  -- If "num_independent_vars" is nil, assume simple linear regression.
  math.randomseed(os.time())

  if (num_independent_vars == nil) then
    num_independent_vars = 1
  end

  self.params={}
  for i=1,num_independent_vars+1,1 do
    -- Arbitrarily chosen range. TODO: Does it matter...?
    table.insert(self.params,math.random(-50,50))
    --table.insert(self.params,1)
  end

end

-- Fit the LinearRegression object
-- X: Matrix object. should be (number of entries) by (number of independent variables)
-- Y: Matrix object. Should be (number of entries) by 1.
-- TODO: how do I specify stochastic vs batch, etc.?
-- TODO: current algos are kind of bad. see https://ruder.io/optimizing-gradient-descent/index.html#gradientdescentvariants
function LinearRegression:fit(X,Y)
    -- TODO: need to pass these as arguments... don't hardcode them!
    alpha =0.005
    epsilon = .001
    momentum = 0.9
    -- TODO: Need a better stopping rule.
    local stochastic_descent = function(params, X, Y,alpha, epsilon)
      current_cost = self:_cost(X,Y)
      last_cost = 0

      -- Used for SGD with momentum
      this_gradient = 0
      last_gradient = 0

      while (math.abs(last_cost-current_cost) > last_cost*.0001) do
        -- Iterate through rows of matrix
        for i, row in ipairs(X.table) do
          -- Compute gradient with respect to single row of X
          this_row_X = Matrix({X.table[i]})
          this_row_Y = Matrix({Y.table[i]})

          this_gradient = self:_gradient(this_row_X,this_row_Y)
          -- update according to this gradient
          for j, parameter in ipairs(self.params) do
            -- 1) Update rule for "vanilla SGD"
            -- self.params[j] = self.params[j] - alpha*this_gradient.table[j][1]
            -- 2) Update rule for "SGD with momentum"
            if (last_gradient == 0) then
              self.params[j] = self.params[j] - alpha*this_gradient.table[j][1]
            else
              self.params[j] = self.params[j] - alpha*this_gradient.table[j][1] - alpha*momentum*last_gradient.table[j][1]
            end
          end

          last_cost = current_cost
          current_cost = self:_cost(X,Y)
          -- used for SGD with momentum
          last_gradient = this_gradient
          print("gradient:")
          print(this_gradient:to_string())
          print("cost")
          print(current_cost)
          print("params")
          print(table.unpack(self.params))
          print()
        end
      end
    end

    local batch_descent = function(params,X,Y,alpha,epsilon)
      current_cost = self:_cost(X,Y)
      last_cost = 0

      while (math.abs(current_cost-last_cost) > epsilon) do
        this_gradient = self:_gradient(X,Y)
        for j, parameter in ipairs(self.params) do
          self.params[j] = self.params[j] - alpha*this_gradient.table[j][1]
        end
        last_cost = current_cost
        current_cost = self:_cost(X,Y)

        print("gradient:")
        print(this_gradient:to_string())
        print("cost")
        print(current_cost)
        print("params")
        print(table.unpack(self.params))
        print()
      end
    end
    stochastic_descent(self.params,X,Y,alpha,epsilon)

    --batch_descent(self.params,X,Y,alpha,epsilon)
end

function LinearRegression:predict(X)
  assert(#self.params == X:shape()[2] + 1, "number of independent variables doesn't match")
  num_independent_vars = #self.params - 1
  local N = math.max(Y:shape()[1], Y:shape()[2])

  fit_func = MultiLinearExpr(num_independent_vars,self.params)
  y_hat = fit_func:compute(X)
  return y_hat
end

-- The cost function for least squares linear regression.
-- X: A matrix of inputs, where rows are tuples / individual entries, columns represent x_1, x_2, x_n.. (for higher order polynomial fitting)
-- Y: The ground truth matrix. n by 1 (vertical vector)
-- Returns an int. Not a Matrix!
function LinearRegression:_cost(X,Y)
  assert(#self.params == X:shape()[2] + 1, "number of independent variables doesn't match")
  num_independent_vars = #self.params - 1
  local N = math.max(Y:shape()[1], Y:shape()[2])

  fit_func = MultiLinearExpr(num_independent_vars,self.params)
  y_hat = fit_func:compute(X)
  abs_error = y_hat:subtract(Y)

  -- Kind of unnecessary, but at least it'll be robust.
  result = abs_error:map(function(x) return 0.5*math.pow(x,2) end)
  result = result:scalar_mult(1/N)
  result = result:sum(1)
  return result.table[1][1]
end

function LinearRegression:_gradient(X,Y)
  assert(#self.params == X:shape()[2] + 1, "number of independent variables doesn't match")
  num_independent_vars = #self.params - 1
  local N = math.max(Y:shape()[1], Y:shape()[2])
  --print("N:" .. N)
  fit_func = MultiLinearExpr(num_independent_vars,self.params)
  y_hat = fit_func:compute(X)
  abs_error = y_hat:subtract(Y)
  -- Now, get the gradient matrix, by doing X*abs_error
  -- X is N by (num_independent_vars+1), abs_error is N by 1
  -- Insert a column of ones for the intercept term
  X_array = X:copy()
	local ones_array = Matrix:ones(X_array:shape()[1],1)
	X_array:insert(1,ones_array.table)

  result = abs_error:transpose()

  --print(X_array:to_string())
  --print(result:to_string())

  result = result:mat_mul(X_array)
  result = result:scalar_mult(1/N)
  --print(result:to_string())
  --print("-------")
  -- We now have 1XN matrix, in descending power.
  return result:transpose()
end
