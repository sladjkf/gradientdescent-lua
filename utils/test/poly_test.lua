require "utils.poly"

expr = MultiLinearExpr(2,{3,2,2})

input = Matrix({{1,2},{3,2},{5,3},{3,2}})

result = expr:compute(input)

print(result:to_string())
