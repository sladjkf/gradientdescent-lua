require "utils.matrix1"

print("Testing Matrix:map()")
-- Expected output
-- Doesn't modify original matrix
print("Testing Matrix:reduce()")
-- Can call self:tranpose() within other functions?

M = Matrix({{1,2,1},{1,2,1}})
print(M:to_string())
result = M:reduce(function(x,y) return x+y end, 1)
print(result:to_string())
print(M:to_string())

result = M:sum(1)
print(result:to_string())

M = Matrix({{1,1,1,1,1}})
print(M:to_string())

result = M:sum(0)
print(result:to_string())

print(type(3))

print("Testing Matrix:flip()")

M = Matrix({{1,2,1},{1,2,2},{2,4,2}})
print(M:to_string())

print("flipping along rows")
result = M:flip(0)
print(result:to_string())


print("flipping along columns")
result = M:flip(1)
print(result:to_string())
