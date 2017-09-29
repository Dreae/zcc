Code = {}

function Code:new()
    new_object = { code = "" }
    self.__index = self

    return setmetatable(new_object, self)
end

function Code:emit(code)
    self.code = self.code..code
end

function generate_code(ast)
    local code = Code:new()
    for i, v in ipairs(ast) do
        v:emit(code)
    end

    return code
end