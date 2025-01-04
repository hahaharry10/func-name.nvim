local debug_mode = true


local function clearFile(file)
    stream = io.open(file, "w")
    stream:write("")
    stream:close()
end

local function _print(value, file)
    -- Write text to log
    if (file == nil) then
        print(vim.inspect(value))
    else
        stream = io.open(file, "a")
        -- print the function dtype and id:
        if( type(value) ~= "string" ) then
            value = vim.inspect(value)
        end
        stream:write(value .. "\n")
        -- for t in string.gmatch(text, "\"[^\"]+\", \"[^\"]+\"") do
        --     stream:write(t .. "\n\t")
        -- end
        -- stream:write(text[1] .. " " .. text[2] .. "\n")
        -- stream:write("\t" .. 
        stream:close()   
    end
end


local function create_buffer()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buf, "myBuffer")
    return buf
end

local buffnr = vim.api.nvim_get_current_buf()

local language_tree = vim.treesitter.get_parser(buffnr, "c")
local syntax_tree = language_tree:parse()
local root = syntax_tree[1]:root()

local logFile = "./log.txt"
clearFile(logFile)


if( debug_mode ) then
    _print([[RUNNING WITH DEBUG MODE!
    Logs starting with DEBUG are outputs that are added for debugging.

    Logs starting with PROGRAM are messages printed part of the default functionality (Messages will stil output out of debug mode).
    ]], logFile)
                
end


-- TODO:
--  Query only captures one parameter.
local query = vim.treesitter.query.parse('c', [[
(function_definition
    type: (_) @func_dtype
    declarator: (function_declarator
        declarator: (identifier) @name
        parameters: (parameter_list
            (parameter_declaration
                type: (_) @param_type
                declarator: (_) @decl
            )
        )
    )
)
]])

if( debug_mode ) then
    package.loaded["nodes"] = nil
end
local nodes = require("nodes")

if( debug_mode ) then
    _print("DEBUG: outputting captures...", logFile)
end

for _, captures, metadata in query:iter_matches(root, buffnr) do
    -- nodes[i] = { func_dtype, func_id, param_dtype, param_id }
    --      many nodes equate to the same function:
    if( debug_mode ) then
        currentCapture = {}
        currentCapture[1] = vim.treesitter.get_node_text(captures[1], buffnr)
        currentCapture[2] =vim.treesitter.get_node_text(captures[2], buffnr)
        currentCapture[3] =vim.treesitter.get_node_range(captures[2])
        currentCapture[4] =vim.treesitter.get_node_text(captures[3], buffnr)
        currentCapture[5] =vim.treesitter.get_node_text(captures[4], buffnr)
        currentCapture[6] =vim.treesitter.get_node_range(captures[4])
        _print(currentCapture, logFile)
    end
    nodes:add_param_node(
        vim.treesitter.get_node_text(captures[1], buffnr),
        vim.treesitter.get_node_text(captures[2], buffnr),
        vim.treesitter.get_node_range(captures[2]),
        vim.treesitter.get_node_text(captures[3], buffnr),
        vim.treesitter.get_node_text(captures[4], buffnr),
        vim.treesitter.get_node_range(captures[4])
    )
end

if( debug_mode ) then
    _print("DEBUG: END OUTPUT!\n\n", logFile)
    _print("DEBUG: Retrieving all nodes from tree...", logFile)
    _print(nodes:get_all_nodes(), logFile)
    _print("DEBUG: END OUTPUT\n\n", logFile)
end

