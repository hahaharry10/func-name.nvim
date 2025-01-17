debug_mode = true


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


-- TODO: Query currently only captures functions with one or more
--      parameter. Change query to capture functions with no parameters.
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
    -- nodes[i] = { func_dtype, func_id, {func_pos_line, func_pos_col}, param_dtype, param_id, {param_pos_line, param_pos_col} }
    -- many nodes equate to the same function as there is only one param to a node.
    
    -- Position only requires starting line and col number.
    local node_pos = { {}, {} }
    local full_pos = { vim.treesitter.get_node_range(captures[2]) }
    node_pos[1] = { full_pos[1], full_pos[2] } 
    full_pos = { vim.treesitter.get_node_range(captures[4]) }
    node_pos[2] = { full_pos[1], full_pos[2] }
    if( debug_mode ) then
        local currentCapture = {}
        currentCapture[1] = vim.treesitter.get_node_text(captures[1], buffnr)
        currentCapture[2] = vim.treesitter.get_node_text(captures[2], buffnr)
        currentCapture[3] = node_pos[1]
        currentCapture[4] = vim.treesitter.get_node_text(captures[3], buffnr)
        currentCapture[5] = vim.treesitter.get_node_text(captures[4], buffnr)
        currentCapture[6] = node_pos[2]
        _print(currentCapture, logFile)
    end

    nodes:add_param_node(
        vim.treesitter.get_node_text(captures[1], buffnr),
        vim.treesitter.get_node_text(captures[2], buffnr),
        node_pos[1],
        vim.treesitter.get_node_text(captures[3], buffnr),
        vim.treesitter.get_node_text(captures[4], buffnr),
        node_pos[2]
    )
end

if( debug_mode ) then
    _print("DEBUG: END OUTPUT!\n\n", logFile)
    _print("DEBUG: Retrieving all nodes from tree...", logFile)
    _print(nodes:get_all_nodes(), logFile)
    _print("DEBUG: END OUTPUT!\n", logFile)
end


-- Create new buffer and return handle. If buffer already exists, just return handle.
local function get_func_map_buffer()
    local buf = vim.fn.bufnr("func-map")
    if( buf ~= -1 ) then
        if( debug_mode ) then
            _print("DEBUG: 'func-map' buffer already exists (buf " .. buf .. ").\n", logFile)
        end
        return vim.fn.bufnr("func-map")
    else
        buf = vim.api.nvim_create_buf(false, true)
        if( buf == 0 ) then
            if( debug_mode ) then
                _print("DEBUG: Failed to create buffer.\n", logFile)
            end
            return nil
        end
        if( debug_mode ) then
            _print("DEBUG: Created new buffer (buffer " .. buf .. ").\n", logFile)
        end
        vim.api.nvim_buf_set_name(buf, "func-map")
        return buf
    end
end

local map_buffer = get_func_map_buffer()
_print("Buffer = " .. map_buffer)


-- TODO: Change format of text so that...
--          - The function and the parameters are as follows:
--                 `func_dtype func_id (p1_type p1_name, p2_type p2_na...)`
--              the functions will be expanded upon user command.
--          - When the function is activated (<TAB>) the source buffer
--              cursor jumps to that source line.
if( debug_mode ) then
    _print(
    "DEBUG: Writing to the buffer:\n\tbuffer number: " .. map_buffer,
    logFile
    )
end
local write_start = 0
for i=1,nodes:get_func_count() do
    local text = {}
    local func_node = nodes:get_func_attributes(i)
    text[1] = "" .. func_node.dtype .. " " .. func_node.id
    local offset = 1
    local params = nodes:get_params(i)
    for j=1,params.count do
        text[j+offset] = "\t" .. params[j].dtype .. " " .. params[j].id
    end

    if( debug_mode ) then
        _print(
            "Writing texts...\n\t\t" .. vim.inspect(text) ..
            "\n\tOn lines...\n\t\tStart: " .. write_start ..
            "\n\t\tEnd: " .. write_start+params.count+offset .. " (non inclusive)",
            logFile
        )
    end

    vim.api.nvim_buf_set_lines(
        map_buffer,
        write_start,
        write_start+params.count+offset,
        false,
        text
    )

    write_start = write_start + params.count + 1
end

if( debug_mode ) then
    _print("DEBUG: END OUTPUT!", logFile)
end

-- We want to only fill a fraction of the window
local window_height = math.floor(vim.api.nvim_win_get_width(0) / 4) + 3

if( debug_mode ) then
    _print("DEBUG: Opening viewport for buffer " .. map_buffer .. " of size " .. window_height, logFile)
end

-- split window left of the screen:
vim.cmd("abo " .. window_height .. "vs | b +set\\ signcolumn=no " .. map_buffer)


