local argparse = require "argparse"

require "lua/lex"
require "lua/parse"
require "lua/generation"

local function read_sources()
    local parser = argparse("zcc", "A C compiler for the ZCPU")
    parser:argument("input", "input file"):args("+")
    parser:option("-o --output", "Output file", "a.out")
    
    local args = parser:parse()
    local files = {}
    for k, v in pairs(args.input) do
        local f, err = io.open(v)
        if f == nil then
            print(err)
            return
        end
        local s = f:read("*a")
        f:close()

        files[v] = s
    end

    for k, v in pairs(files) do
        local token_stream = tokenize_source(v)
        if token_stream.has_error then
            print(token_stream.msg)
        else
            local ast = parse_token_stream(token_stream)
            local code = generate_code(ast)

            print(code.code)
        end
    end
end

read_sources()