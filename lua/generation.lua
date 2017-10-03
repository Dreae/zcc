Code = {}
function Code:new()
    local new_object = { 
        code = "",
        registers = Registers:new(),
        globals = {},
        variables = {},
        offset = 0,
        current_label = 0
    }
    self.__index = self

    return setmetatable(new_object, self)
end

function Code:store_string(str)
    local label = self.current_label
    self:emit("_"..label..': db "'..str..'", 0')
    self.current_label = self.current_label + 1
    self.offset = self.offset + #str + 1

    return label
end

function Code:push_immed(val)
    local register = self.registers:get_free_gpr()
    self:emit("mov "..register.mnemonic..", "..val.."\n")

    return register
end

function Code:emit(code)
    self.code = self.code..code
    self.offset = self.offset + 1
end

function generate_code(ast)
    local code = Code:new()
    for i, v in ipairs(ast) do
        v:emit(code)
    end

    return code
end

Registers = {}
function Registers:new()
    local new_object = {
        eax = Register:new("eax"),
        ebx = Register:new("ebx"),
        ecx = Register:new("ecx"),
        edx = Register:new("edx"),
        scratch_registers = {}
    }
    self.__index = self
    
    for i = 0, 31 do
        new_object.scratch_registers[i] = Register:new("r"..i)
    end

    return setmetatable(new_object, self)
end

function Registers:get_free_gpr()
    if self.eax.free then
        self.eax.free = false
        return self.eax
    elseif self.ebx.free then
        self.ebx.free = false
        return self.ebx
    elseif self.ecx.free then
        self.ecx.free = false
        return self.ecx
    elseif self.edx.free then
        self.edx.free = false
        return self.edx
    else
        for i = 0, 31 do
            if self.scratch_registers[i].free then
                self.scratch_registers[i].free = false

                return self.scratch_registers[i]
            end
        end
    end
end

Register = {}
function Register:new(mnemonic)
    local new_object = {
        free = true,
        mnemonic = mnemonic
    }
    self.__index = self

    return setmetatable(new_object, self)
end