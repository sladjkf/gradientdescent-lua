require "utils.class.class"
Matrix = class()
Matrix:set{
	table = {},
}


-- MATRIX CREATION

-- Create a new Matrix.
-- input_table - the table to initialize the Matrix with.
function Matrix:init(input_table)
	-- TODO: Set the function of the * symbol (scalar multiplication)

	-- TODO: Set the function of the - symbol (scalar/element by element subtraction)

	-- Initialize the internal table
	self.table = input_table or {}

	-- Validate the dimensions of the table
	rows = #input_table
	columns = #input_table[1]
	for i,v in ipairs(input_table) do
		assert(#v == columns, "dimension mismatch")
	end

	-- Set the shape of the table
	-- self.shape = {rows,columns}

	return o
end

-- TODO: manually callable, how do I get it to just work without calling
-- TODO: implement padding for long decimals
-- Set the tostring method
function Matrix:to_string()
	returnstring = ""
	for i,row in ipairs(self.table) do
		returnstring = returnstring .. "["
		for j,col in ipairs(row) do
			returnstring = returnstring .. col .. " "
		end
		returnstring = returnstring .. "]\n"
	end
	return returnstring
end

-- Check if the current matrix equals another given matrix.
-- Returns true if it it's equal, false otherwise.
-- TODO: function Matrix:equals(matrix_B)

-- Private utility function.
-- Create a m,n matrix where every element is the number "num"
function Matrix:nums(m,n,num)
	table_representation = {}
	-- Populate the table with empty rows.
	for i=1,m do
		table.insert(table_representation,{})
	end
	for i,row in ipairs(table_representation) do
		for j=1,n do
			table.insert(row,num)
		end
	end

	return Matrix(table_representation)
end

-- Create a m-by-n matrix of ones.
function Matrix:ones(m,n)
	return Matrix:nums(m,n,1)
end

-- Create a m-by-n matrix of zeros.
-- Intended to be called "statically"
function Matrix:zeros(m,n)
	return Matrix:nums(m,n,0)
end

-- TODO: Create a n-by-n identity matrix.
function Matrix:identity()
end

-- MATRIX UTILITIES

-- Apply the function "func" to every element in the matrix.
-- func: A function accepting one float input, returns one float output
-- Returns a new matrix with the operation applied.
function Matrix:map(func)
	return_matrix = Matrix:zeros(#self.table,#self.table[1])
	for i, row in ipairs(self.table) do
		for j, col in ipairs(row) do
			return_matrix.table[i][j] = func(col)
		end
	end
	return return_matrix
end

-- Apply the function to reduce along rows or columns.
-- func: A function accepting 2 float inputs, returning one float output
-- axis: 0 to apply along rows, 1 to apply along columns
-- TODO: "order": 0 to reduce from (left->right // top->bottom) or (right->left / bottom->top)
function Matrix:reduce(func,axis)
	assert(axis == 0 or axis == 1, "invalid axis")

	operating_matrix = self
	-- If operating along columns, simply turn them into rows
	-- then transpose back afterwards.
	if (axis == 1) then
		operating_matrix = self:transpose()
	end

	local return_matrix = Matrix:zeros(operating_matrix:shape()[1],1)
	--print(return_matrix:to_string())
	-- perform the reduce operation
	for i,row in ipairs(operating_matrix.table) do
		local last_value = row[1]
		for j=2,#row do
			last_value = func(last_value,row[j])
		end
		--print(last_value)
		return_matrix.table[i][1] = last_value
	end
	--print(return_matrix:to_string())
	if (axis ==1) then
		return_matrix = return_matrix:transpose()
	end
	return return_matrix
end

-- Convenience function that calls Matrix:reduce() to sum along rows or columns.
-- TODO: move to another category?
function Matrix:sum(axis)
	return self:reduce(function(x,y) return x+y end,axis)
end

-- TODO
-- Takes func, function accepting 2 float arguments, and performs them element by element
-- on matrix B.
-- func: function accepting 2 args, returning 1
-- B: matrix of same shape as self.
function Matrix:el_by_el(func,B)
	--print(table.unpack(self:shape()))
	--print(table.unpack(B:shape()))
	assert(self:shape()[1] == B:shape()[1], "Number of rows don't match")
	assert(self:shape()[2] == B:shape()[2], "Number of columns don't match")

	local return_matrix = Matrix:zeros(self:shape()[1],self:shape()[2])
	for i, row in ipairs(self.table) do
		for j, entry in ipairs(row) do
			return_matrix.table[i][j] = func(self.table[i][j],B.table[i][j])
		end
	end

	return return_matrix
end

function Matrix:shape()
	return {#self.table,#self.table[1]}
end

-- Return a copy of the given matrix.
function Matrix:copy()
	local return_matrix = Matrix:zeros(self:shape()[1],self:shape()[2])
	for i,row in ipairs(self.table) do
		for j,entry in ipairs(row) do
			return_matrix.table[i][j] = entry
		end
	end
	return return_matrix
end

-- TODO
-- Get the element at m,n.
-- If either argument is nil, get that row or column
-- function Matrix:index(m,n)
-- 	if (m == nil) then
-- 		-- oh god oh fuck indexing columns
-- 	else if (n == nil) then
-- 		-- TODO
-- 	else
-- 	end
-- end
-- MATRIX MANIPULATION

-- add a row or a column.
-- axis - 0 to insert along rows, 1 to insert along columns
-- input_table - the table or column to insert
-- index - at which index to insert the row or column. if nil, append
-- TODO: validate function behavior... adding along rows works okay but what about columns?
-- TODO: update so input_table is a Matrix rather than a table
function Matrix:insert (axis, input_table, index)
	-- validate 'axis' input
	assert(axis == 0 or axis == 1, "invalid axis")
	local shape = self:shape()
	-- add a row
	if (axis == 0) then
		-- Make sure number of columns match.
		assert(shape[2] == #input_table[1], "dimension mismatch")

		-- If index nil, append, otherwise insert at index
		if (index == nil) then
			table.insert(self.table,table.unpack(input_table))
		else
			-- Validate index
			assert((1 <= index and index <= shape[1]+1), "index out of bounds")
			table.insert(self.table,index,table.unpack(input_table))
		end
	-- add a column
	-- TODO: as written, this only supports adding 1 column.
	else
		-- Make sure number of rows match.
		assert(shape[1] == #input_table, "dimension mismatch")

		if (index == nil) then
			-- Simply append if nil
			for i,v in ipairs(self.table) do
				table.insert(self.table[i],input_table[i][1])
			end
		else
			for i,v in ipairs(self.table) do
				-- Validate index
				assert((1 <= index and index <= shape[0]+1), "index too large")
				table.insert(self.table[i],input_table[i][1],index)
			end
		end

	end

end

-- Remove the column or row at index "index".
-- If index is null, remove the last element.
-- TODO: function Matrix:remove(axis,index)

-- Tranpose the matrix, swapping rows for columns and columns for rows.
-- Does not modify the original matrix
function Matrix:transpose()
	local return_matrix = Matrix:zeros(self:shape()[2],self:shape()[1])
	for i,row in ipairs(self.table) do
		for j, col in ipairs(row) do
			return_matrix.table[j][i] = col
		end
	end
	return return_matrix
end

-- function Matrix:reshape(m,n)
-- end
-- TODO: Matrix:slice()

-- Reverse the elements in a matrix along a given axis.
-- 0 to flip along rows. 1 to flip along columns.
function Matrix:flip(axis)
	assert(axis==0 or axis==1, "invalid axis")

	local reverse_table = function(row)
		for i=1, math.floor(#row / 2) do
			local tmp = row[i]
    	row[i] = row[#row - i + 1]
    	row[#row - i + 1] = tmp
		end
	end
	local return_matrix = self:copy()
	-- flip along rows
	-- reverse every individual subtable
	if (axis==0) then
		for i, row in ipairs(return_matrix.table) do
			reverse_table(row)
		end

	-- flip along columns
	-- just reverse the rows
	else
		local num_rows = return_matrix:shape()[1]
		reverse_table(return_matrix.table)
	end

	return return_matrix
end

-- MATRIX OPERATIONS

-- Matrix multiplication.
-- b: Another matrix object
function Matrix:mat_mul(b)
	--print(self.table[1][1])
	--print(#self.table[1] .. "," .. b:shape()[1])
	assert(#self.table[1] == b:shape()[1], "dimension mismatch")

	return_matrix = Matrix:zeros(self:shape()[1],b:shape()[2])

	-- Iterate across rows from this table
	for rownum_a, row in ipairs(self.table) do
		-- Iterate across columns from 'b'
		for colnum_b=1,b:shape()[2] do
			--Iterate across entries
			local sum = 0
			for k, entry in ipairs(row) do
				sum = sum + self.table[rownum_a][k]*b.table[k][colnum_b]
			end
			return_matrix.table[rownum_a][colnum_b] = sum
		end
	end
	return return_matrix
end

-- Element by element multiplication.
-- b: another matrix object.
function Matrix:hadamard(b)
	return self:el_by_el(function(x,y) return x*y end,b)
end

function Matrix:add(b)
	return self:el_by_el(function(x,y) return x+y end,b)
end

function Matrix:subtract(b)
	return self:el_by_el(function(x,y) return x-y end,b)
end

-- Scalar multiplication
function Matrix:scalar_mult(num)
	local shape = self:shape()
	-- Create a "nums" matrix of the same size and do element by element
	to_multiply = Matrix:nums(shape[1],shape[2],num)
	return self:hadamard(to_multiply)
end
--Vector = {shape = 0, table = {}}

--function Vector:new (o,input_table)
--end

--local m = Matrix({{1,2},{1,2}})
--local p = Matrix({{1,2},{1,2}})

--m:map(function(x) return x+1 end)

--print(m)
--print(p)
