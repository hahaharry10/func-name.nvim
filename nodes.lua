local nodes = {}

nodes.count = 0

function nodes:create_empty_func_node(dtype, id, pos)
    self.count = self.count + 1
    self[self.count] = {}

    self[self.count].dtype = dtype
    self[self.count].id = id
    self[self.count].pos = pos
    self[self.count].param_count = 0
    self[self.count].params = {}
end

function nodes.create_param_node(dtype, id, pos)
    local node = {}
    node.dtype = dtype
    node.id = string.gsub(id, "%s", "")
    node.pos = pos

    return node
end

-- Add the parameter node to the corresponding function node.
-- If the function node does not exist, create one.
function nodes:add_param_node(
    func_dtype,
    func_id,
    func_pos,
    param_dtype,
    param_id,
    param_pos
)

    local is_found = false
    for i=1,self.count do
        if( self[i].id == func_id and self[i].pos == func_pos ) then
            local func_node = self[i]
            func_node.param_count = func_node.param_count + 1
            func_node.params[func_node.param_count] = self.create_param_node(
                param_dtype,
                param_id,
                param_pos
            )
            is_found = true
            break
        end
    end

    if( not is_found ) then
        -- If the func node is not created yet...
        self:create_empty_func_node(func_dtype, func_id, func_pos)
        local new_node = self[self.count]
        new_node.param_count = new_node.param_count + 1
        new_node.params[new_node.param_count] = self.create_param_node(
            param_dtype,
            param_id,
            param_pos
        )
    end
end

function nodes:get_all_nodes()
    local output = ""
    for i=1,self.count do
        output = output .. self[i].dtype .. " "
        output = output .. self[i].id .. " "
        output = output .. self[i].pos .. "\n"
        for j=1,self[i].param_count do
            output = output .. "\t" .. self[i].params[j].dtype .. " "
            output = output .. self[i].params[j].id .. " "
            output = output .. self[i].params[j].pos ..  "\n"
        end
        if( i ~= self.count ) then
            output = output .. "\n"
        end
    end

    return output
end

function nodes:hardcode_test_values()
    for i=1,self.count do
        self[i] = {}
    end

    self[1] = {}
    self[1].dtype = "dtype_1"
    self[1].id = "func_1"
    self[1].pos = 1
    self[1].param_count = 0
    self[1].params = {}

    self[2] = {}
    self[2].dtype = "dtype_2"
    self[2].id = "func_2"
    self[2].pos = 2
    self[2].param_count = 1
    self[2].params = {}
    self[2].params[1] = {}
    self[2].params[1].dtype = "dtype_a"
    self[2].params[1].id = "param_a"
    self[2].params[1].pos = 2.1

    self[3] = {}
    self[3].dtype = "dtype_3"
    self[3].id = "func_3"
    self[3].pos = 3
    self[3].param_count = 2
    self[3].params = {}
    self[3].params[1] = {}
    self[3].params[1].dtype = "dtype_a"
    self[3].params[1].id = "param_a"
    self[3].params[1].pos = 3.1
    self[3].params[2] = {}
    self[3].params[2].dtype = "dtype_b"
    self[3].params[2].id = "param_b"
    self[3].params[2].pos = 3.2

    self[4] = {}
    self[4].dtype = "dtype_4"
    self[4].id = "func_4"
    self[4].pos = 4
    self[4].param_count = 3
    self[4].params = {}
    self[4].params[1] = {}
    self[4].params[1].dtype = "dtype_a"
    self[4].params[1].id = "param_a"
    self[4].params[1].pos = 4.1
    self[4].params[2] = {}
    self[4].params[2].dtype = "dtype_b"
    self[4].params[2].id = "param_b"
    self[4].params[2].pos = 4.2
    self[4].params[3] = {}
    self[4].params[3].dtype = "dtype_c"
    self[4].params[3].id = "param_c"
    self[4].params[3].pos = 4.3

    self.count = 4
end

return nodes
