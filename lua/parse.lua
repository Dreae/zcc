require "lua/ast"

Parser = {}

function Parser:new(token_stream)
    new_object = { 
        token_stream = token_stream, 
        root_node = Node:new(NodeType.Root),
        halt = false,
        pos = 1,
        current_token = nil
    }
    self.__index = self

    return setmetatable(new_object, self)
end

function Parser:parse()
    while not self.halt do
        self:consume()
        if self.current_token == nil then
            return self.root_node
        end

        if self.current_token.token_type == TokenType.Literal then
            table.insert(self.root_node, self:read_expression())
        end
    end
end

function Parser:consume()
    self.current_token = self.token_stream[self.pos]
    self.pos = self.pos + 1

    return token
end

function Parser:peek()
    return self.token_stream[self.pos]
end

function Parser:read_statement()
    
end

function Parser:read_expression()
    local node = IntLiteral:new(self.current_token.value)

    self:consume()
    if self.current_token.token_type == TokenType.Operator then
        local op = self.current_token
        self:consume()
        local right = self:read_expression()
        -- TODO: Make this a lookup table
        if op.value == '+' then
            return Add:new(node, right)
        elseif op.value == '-' then
            return Subtract:new(node, right)
        elseif op.value == "*" then
            return Multiply:new(node, right)
        elseif op.value == "/" then
            return Divide:new(node, right)
        end
    elseif self.current_token.token_type == TokenType.Semicolon then
        return node
    end
end

function parse_token_stream(token_stream)
    local parser = Parser:new(token_stream)

    return parser:parse()
end