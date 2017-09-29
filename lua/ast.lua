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
    Assignment=8
}

function Node:new(node_type) 
    new_object = { node_type = node_type }
    self.__index = self

    return setmetatable(new_object, self)
end

function Node:emit(code)
    code:emit(self:generate())
end

Statement = Node:new(NodeType.Statement)
Expression = Node:new(NodeType.Expression)
function Expression:new(body)
    new_object = { body = body }
    self.__index = self

    return setmetatable(new_object, self)
end

function Expression:generate()
    return self.body:generate()
end

IntLiteral = Node:new(NodeType.IntLiteral)
function IntLiteral:new(num)
    new_object = { value = num }
    self.__index = self

    return setmetatable(new_object, self)
end

function IntLiteral:generate()
    return "push "..self.value.."\n"
end

Add = Node:new(NodeType.Add)
function Add:new(left, right)
    new_object = { left = left, right = right }
    self.__index = self

    return setmetatable(new_object, self)
end

function Add:generate()
    local code = ""
    code = code..self.left:generate()
    code = code..self.right:generate()
    code = code.."pop eax\n"
    code = code.."pop ebx\n"
    code = code.."add eax, ebx\n"

    return code
end