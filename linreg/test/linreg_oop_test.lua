require "linreg.linreg_oop"

LR = LinearRegression(2)

--print(table.unpack(LR.params))

-- training example 1
-- desired eqn: 0.53527X1 + 0.45021X2 + 0.30083
-- X = Matrix({{1,6,3,7,4},{9,5,4,2,5}})
-- X = X:transpose()
-- Y = Matrix({{7,4,3,8,2}})
-- Y = Y:transpose()

-- Tranining example 2
-- Desired eqn: ŷ = 1.57792X1 + 1.1955X2 - 8.81103
X = Matrix({{1,6,3,2,6,3},{10,3,6,32,4,5}})
X = X:transpose()
Y = Matrix({{2,6,6,33,2,3}})
Y = Y:transpose()


-- Extremely simply training example
--X = Matrix({{1,2,3,4,5,6}})
--X = X:transpose()
--Y = Matrix({{1,2,3,4,5,6}})
--Y = Y:transpose()
--result = LR:_cost(X,Y)
print(result)
result = LR:_gradient(X,Y)

--print(result:to_string())

LR:fit(X,Y)

print(table.unpack(LR.params))

y_hat = LR:predict(X)
print(y_hat:to_string())
