--[[
	Result.luau
	
	An object that wraps values to represent success or failure.
]]

--------------------------------------------------------------------------------
-- TYPES
--------------------------------------------------------------------------------

type ResultClass = {
	
}

export type Result<T, E> = {
	
}

local Result = {} :: ResultClass

function Result.ok(value)
	return setmetatable({
		_isOk = true,
		_value = value,
	}, Result)
end

function Result.err(err)
	return setmetatable({
		_isOk = false,
		_err = err,
	}, Result)
end

function Result:Map(transformer)
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end
	
	if type(transformer) ~= "function" then
		error("InvalidArgument: 'transformer' must be a function", 2)
	end
	
	if not self._isOk then
		return self
	end
	
	return Result.ok(transformer(self._value))
end

function Result:MapErr(transformer)
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end

	if type(transformer) ~= "function" then
		error("InvalidArgument: 'transformer' must be a function", 2)
	end

	if self._isOk then
		return self
	end

	return Result.err(transformer(self._err))
end

function Result:AndThen(handler)
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end
	
	if type(handler) ~= "function" then
		error("InvalidArgument: 'handler' must be a function", 2)
	end
	
	if not self._isOk then
		return self
	end
	
	local result = handler(self._value)
	
	if getmetatable(result) ~= Result then
		error("InvalidArgument: 'handler' must return a Result", 2)
	end
	
	return result
end

function Result:OrElse(handler)
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end

	if type(handler) ~= "function" then
		error("InvalidArgument: 'handler' must be a function", 2)
	end

	if self._isOk then
		return self
	end

	local result = handler(self._err)

	if getmetatable(result) ~= Result then
		error("InvalidArgument: 'handler' must return a Result", 2)
	end

	return result
end

function Result:Match(handlers)
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end

	if type(handlers) ~= "table" or type(handlers.ok) ~= "function" or type(handlers.err) ~= "function" then
		error("InvalidArgument: 'handlers' must be a table containing functions 'ok' and 'err'", 2)
	end
	
	if self._isOk then
		return handlers.ok(self._value)
	end
	
	return handlers.err(self._err)
end

function Result:Inspect(inspector)
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end

	if type(inspector) ~= "function" then
		error("InvalidArgument: 'inspector' must be a function", 2)
	end
	
	if self._isOk then
		inspector(self._value)
	end
	
	return self
end

function Result:InspectErr(inspector)
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end

	if type(inspector) ~= "function" then
		error("InvalidArgument: 'inspector' must be a function", 2)
	end

	if not self._isOk then
		inspector(self._err)
	end

	return self
end

function Result:Unwrap()
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end
	
	if not self._isOk then
		error("LogicalError: unwrapping value of err Result", 2)
	end
	
	return self._value
end

function Result:UnwrapErr()
	if getmetatable(self) ~= Result then
		error("InvalidArgument: 'result' must be a Result", 2)
	end
	
	if self._isOk then
		error("LogicalError: unwrapping error of ok result", 2)
	end

	return self._err
end

function Result:__index(index)
	if index == "isOk" then
		return self._isOk
	end
	
	if index == "isErr" then
		return not self._isOk
	end
	
	return Result[index]
end

function Result:__newindex(index, value)
	if index == "isOk" or index == "isErr" then
		error("TypeError: assignment to read-only property", 2)
	end
	
	rawset(self, index, value)
end

function Result:__tostring()
	
end

function Result:__eq(other)
	if getmetatable(other) ~= Result then
		return false
	end
	
	if other._isOk ~= self._isOk then
		return false
	end
	
	if other._isOk then
		return other._value == self._value
	end
	
	return other._err == self._err
end

return Result