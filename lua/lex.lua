Token = {}
TokenType = {
    Semicolon = 0,
    Ident = 1,
    Primative = 2,
    Literal = 3,
    Operator = 4,
    Keyword = 5,
    OpenParen = 6,
    CloseParen = 7,
    OpenBracket = 8,
    CloseBracket = 9,
    OpenSqBracket = 10,
    CloseSqBracket = 11,
    Comma = 12,
    ConstString = 13
}

local operators = "+-*/=&<>"
local primatives = " int float char short long void "
local keywords = " if else while for break return unsigned typedef struct union "
local alpha_num = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

function Token:new(token_type, value)
    local new_object = { token_type = token_type, value = value }
    self.__index = self 

    return setmetatable(new_object, self)
end

function Token:get_type()
    return self.token_type
end

TokenStream = {}

function TokenStream:new()
    local new_object = { has_error = false, msg = "" }
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
    local new_object = { 
        source = source, 
        char = "", 
        pos = 1, 
        token_stream = TokenStream:new(),
        halt = false,
    }

    self.__index = self

    return setmetatable(new_object, self)
end

function Tokenizer:parse()
    local function contains(str, char)
        local p = 1
        local s = str:sub(p, p)
        while s ~= "" do
            if s == char then
                return true
            end

            p = p + 1
            s = str:sub(p, p)
        end

        return false
    end

    while not self.halt do  
        self:read_char()
        if self.char == nil then
            break
        end

        if string.find(self.char, "%s") == nil then
            if string.find(self.char, "%d") then
                table.insert(self.token_stream, self:read_num())
            elseif contains(operators, self.char) then
                table.insert(self.token_stream, self:read_operator())
            elseif self.char == ";" then
                table.insert(self.token_stream, Token:new(TokenType.Semicolon))
            elseif self.char == "(" then
                table.insert(self.token_stream, Token:new(TokenType.OpenParen))
            elseif self.char == ")" then
                table.insert(self.token_stream, Token:new(TokenType.CloseParen))
            elseif self.char == "{" then
                table.insert(self.token_stream, Token:new(TokenType.OpenBracket))
            elseif self.char == "}" then
                table.insert(self.token_stream, Token:new(TokenType.CloseBracket))
            elseif self.char == "[" then
                table.insert(self.token_stream, Token:new(TokenType.OpenSqBracket))
            elseif self.char == "]" then
                table.insert(self.token_stream, Token:new(TokenType.CloseSqBracket))
            elseif self.char == "," then
                table.insert(self.token_stream, Token:new(TokenType.Comma))
            elseif self.char == '"' then
                table.insert(self.token_stream, self:read_string())
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

function Tokenizer:peek()
    if self.pos == #self.source + 1 then
        return nil
    else
        return self.source:sub(self.pos, self.pos)
    end
end

function Tokenizer:rewind(num)
    self.pos = self.pos - num - 1
    self:read_char()
end

function Tokenizer:consume()
    local str = self.char
    local num = 0
    while self:peek():match("%w") ~= nil do
        self:read_char()
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

    if string.find(primatives, " "..t.." ") ~= nil then
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

    if string.find(keywords, " "..t.." ") ~= nil then
        return Token:new(TokenType.Keyword, t)
    end

    self:rewind(num)
    return nil
end

function Tokenizer:read_ident()
    if self.char:match("%a") == nil then
        self:expected("Identifier")
    end

    return Token:new(TokenType.Ident, self:consume())
end

function Tokenizer:read_operator()
    return Token:new(TokenType.Operator, self.char)
end

function Tokenizer:read_string()
    local next_char = self:peek()
    local str = ""
    while next_char ~= "\n" and next_char ~= '"' and next_char ~= nil do
        str = str..next_char
        self:read_char()

        next_char = self:peek()
    end
    if next_char == "\n" then
        self:expected('"')
    else
        self:read_char()
    end

    return Token:new(TokenType.ConstString, str)
end

function tokenize_source(source)
    local tokenizer = Tokenizer:new(source)
    
    return tokenizer:parse()
end