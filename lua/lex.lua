Token = {}
TokenType = {
    Semicolon = 0,
    Ident = 1,
    Primative = 2,
    Literal = 3,
    Operator = 4,
    Keyword = 5
}

local operators = "+-*/="
local primatives = "int float char short long void"
local keywords = "if else while for break return unsigned"

function Token:new(token_type, value)
    new_object = { token_type = token_type, value = value }
    self.__index = self 

    return setmetatable(new_object, self)
end

function Token:get_type()
    return self.token_type
end

TokenStream = {}

function TokenStream:new()
    new_object = { has_error = false, msg = "" }
    self.__index = self

    return setmetatable(new_object, self)
end

function TokenStream:abort(msg)
    self.has_error = true
    self.msg = msg
end

function TokenStream:expected(expectation)
    self:abort("Expected "..expectation)
end

Tokenizer = {}

function Tokenizer:new(source)
    new_object = { 
        source = source, 
        char = "", 
        pos = 1, 
        token_stream = TokenStream:new(),
        halt = false
    }

    self.__index = self

    return setmetatable(new_object, self)
end

function Tokenizer:parse()
    while not self.halt do  
        self:read_char()
        if self.char == nil then
            break
        end

        if string.find(self.char, "%s") == nil then
            if string.find(self.char, "%d") then
                table.insert(self.token_stream, self:read_num())
            elseif string.find(operators, self.char) then
                table.insert(self.token_stream, self:read_operator())
            elseif self.char == ";" then
                table.insert(self.token_stream, Token:new(TokenType.Semicolon))
            else
                local token = self:read_primative()
                if token then
                    table.insert(self.token_stream, token)
                else
                    token = self:read_keyword()
                    if token then
                        table.insert(self.token_stream, token)
                    else
                        table.insert(self.token_stream, self:read_ident())
                    end
                end
            end
        end

    end

    return self.token_stream
end

function Tokenizer:expected(expectation)
    self.token_stream:expected(expectation)
    self.halt = true
end

function Tokenizer:read_char()
    if self.pos == #self.source + 1 then
        self.char = nil
    else
        self.char = self.source:sub(self.pos, self.pos)

        self.pos = self.pos + 1
    end
end

function Tokenizer:rewind(num)
    self.pos = self.pos - num
end

function Tokenizer:consume()
    local str = self.char
    local num = 0
    while string.find(self.char, "%s") == nil do
        str = str..self.char
        num = num + 1
    end

    return str, num
end

function Tokenizer:read_num()
    local num = tonumber(self.char)
    if num == nil then
        self:expected("Integer")
        return nil
    end

    return Token:new(TokenType.Literal, num)
end

function Tokenizer:read_primative()
    if string.find(self.char, "%a") == nil then
        return nil
    end

    local t, num = self:consume()

    if string.find(primatives, t) ~= nil then
        return Token:new(TokenType.Primative, t)
    end

    self:rewind(num)
    return nil
end

function Tokenizer:read_keyword()
    if string.find(self.char, "%a") == nil then
        return nil
    end

    local t, num = self:consume()

    if string.find(keywords, t) ~= nil then
        return Token:new(TokenType.Keyword, t)
    end

    self:rewind(num)
    return nil
end

function Tokenizer:read_ident()
    if string.find(self.char, "%a") == nil then
        self:expected("Identifier")
    end

    return Token:new(TokenType.Ident, self:consume())
end

function Tokenizer:read_operator()
    return Token:new(TokenType.Operator, self.char)
end

function tokenize_source(source)
    local tokenizer = Tokenizer:new(source)
    
    return tokenizer:parse()
end