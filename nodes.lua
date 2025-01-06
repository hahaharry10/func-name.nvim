local nodes = {}

nodes.count = 0

function nodes:create_empty_func_node(dtype, id, pos)
    self.count = self.count + 1
    self[self.count] = {}

    self[self.count].dtype = dtype
    self[self.count].id = id
    self[self.count].pos = {}
    self[self.count].pos.line = pos[1]
    self[self.count].pos.col = pos[2]
    self[self.count].param_count = 0
    self[self.count].params = {}
end

function nodes.create_param_node(dtype, id, pos)
    local node = {}
    node.dtype = dtype
    node.id = string.gsub(id, "%s", "") -- Remove white space in id
    node.pos = {}
    node.pos.line = pos[1]
    node.pos.col = pos[2]

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
        if( self[i].id == func_id and self[i].pos.line == func_pos[1] and self[i].pos.col == func_pos[2] ) then
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
        output = output .. self[i].id .. " [ "
        output = output .. self[i].pos.line .. " , "
        output = output .. self[i].pos.col .. " ]" .. "\n"
        for j=1,self[i].param_count do
            output = output .. "\t" .. self[i].params[j].dtype .. " "
            output = output .. self[i].params[j].id .. " [ "
            output = output .. self[i].params[j].pos.line .. " , "
            output = output .. self[i].params[j].pos.col .. " ]" .. "\n"
        end
        if( i ~= self.count ) then
            output = output .. "\n"
        end
    end

    return output
end

function nodes:get_func_count()
    return self.count
end

-- These getter functions have the following parameters:
-- - func_id: can either be a number or string.
--      number -> The function is found using func_id as the index.
--      string -> The function is found by comparing the functions name (id)
--                  to func_id
--   If func_id is invalid, nil is returned.
function nodes:get_func_node(func_id)
    if( type(func) == "number" ) then
        if( func_id > self.count ) then
            return nil
        end
        return self[func_id]
    elseif( type(func) == "string" ) then
        for i=1,self.count do
            if( self[i].id == func_id ) then
                return self[i]
            end
        end

        return nil
    else
        return nil
    end
end

-- return all function node attributes apart from the parameter data.
function nodes:get_func_attributes(func_id)
    if( type(func_id) == "number" ) then
        if( func_id > self.count ) then
            return nil
        end

        return {
            dtype = self[func_id].dtype,
            id = self[func_id].id,
            pos = self[func_id].pos
        }
    elseif( type(func_id) == "string" ) then
        local func_index
        local is_found = false
        for i=1,self.count do
            if( self[i].id == func_id ) then
                func_index = i
                is_found = true
                break
            end
        end

        if( not is_found ) then
            return nil
        end

        return {
            dtype = self[func_index].dtype,
            id = self[func_index].id,
            pos = self[func_index].pos
        }
    else
        return nil
    end
end

function nodes:get_params(func_id)
    local params = {}
    if( type(func_id) == "number" ) then
        if( func_id > self.count ) then
            return nil
        end

        params.count = self[func_id].param_count

        for i=1,params.count do
            params[i] = self[func_id].params[i]
        end
    elseif( type(func_id) == "string" ) then
        local func_index
        local is_found = false
        for i=1,self.count do
            if( self[i].id == func_id ) then
                func_index = i
                is_found = true
                break
            end
        end

        if( not is_found ) then
            return nil
        end

        params.count = self[func_index].param_count

        for i=1,param.count do
            params[i] = self[func_index].params[i]
        end
    else
        return nil
    end

    return params
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
