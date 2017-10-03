Node = {}

NodeType = {
    Root=-1,
    Statement=0,
    Expression=1,
    IntLiteral=2,
    FloatLiteral=3,
    StringLiteral=4,
    CharLiteral=5,
    Add=6,
    Subtract=7,
    Multiply=8,
    Divide=9,
    Assignment=10,
    Block=11,
    FunctionDecl=12,
    Ident=13,
    Deref=14
}

__node_id = 0

function Node:new(node_type) 
    local new_object = { node_type = node_type, id = __node_id }
    __node_id = __node_id + 1
    self.__index = self

    return setmetatable(new_object, self)
end

function Node:emit(code)
    self:generate(code)
end

Statement = Node:new(NodeType.Statement)
Expression = Node:new(NodeType.Expression)
function Expression:new(body)
    local new_object = { body = body }
    self.__index = self

    return setmetatable(new_object, self)
end

function Expression:generate()
    return self.body:generate()
end

Ident = {}
function Ident:new(name)
    local new_object = { name = name }
    self.__index = self

    return setmetatable(new_object, self)
end

Deref = {}
function Deref:new(target)
    local new_object = { target = target }
    self.__index = self

    return setmetatable(new_object, self)
end

IntLiteral = Node:new(NodeType.IntLiteral)
function IntLiteral:new(num)
    local new_object = { value = num }
    self.__index = self

    return setmetatable(new_object, self)
end

function IntLiteral:generate(generator)
    return generator:push_immed(self.value)
end

BinOp = Node:new()
function BinOp:new(node_type, ins)
    local new_object = { node_type = node_type, ins = ins }
    self.__index = self

    return setmetatable(new_object, self)
end

function BinOp:generate(generator)
    local register = self.left:generate(generator)
    if self.right.node_type == NodeType.IntLiteral or self.right.node_type == NodeType.FloatLiteral then
        generator:emit(self.ins.." "..register.mnemonic..", "..self.right.value.."\n")
    else
        temp_register = self.right:generate(generator)
        generator:emit(self.ins.." "..register.mnemonic..", "..temp_register.mnemonic.."\n")

        temp_register.free = true
    end

    return register
end

Add = BinOp:new(NodeType.Add, "add")
function Add:new(left, right)
    local new_object = { left = left, right = right }
    self.__index = self

    return setmetatable(new_object, self)
end

Subtract = BinOp:new(NodeType.Subtract, "sub")
function Subtract:new(left, right)
    local new_object = { left = left, right = right }
    self.__index = self

    return setmetatable(new_object, self)
end

Multiply = BinOp:new(NodeType.Multiply, "mul")
function Multiply:new(left, right)
    local new_object = { left = left, right = right }
    self.__index = self

    return setmetatable(new_object, self)
end

Divide = BinOp:new(NodeType.Divide, "div")
function Divide:new(left, right)
    local new_object = { left = left, right = right }
    self.__index = self

    return setmetatable(new_object, self)
end