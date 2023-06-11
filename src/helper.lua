_G=require("memory")
--[[
the findFrom function is a network searching algorithm for memory
objects are merely logical singletons/nodes in memory, an actual 'object'
is constructed from many objects, links and actions in conjunction with each
other. An actual 'object' can be represented by a chunk of a network and this
algorithm works to find that object by respecting the other nodes in the chunk
]]
helper = {}
helper.result = function(space,name)
    return function(result)
        space[name] = result
    end
end
helper.by = function(byTerm)
    return function(link)
        local print = blank
        print(" by",link,byTerm)
        if link.by == byTerm then return true end
    end
end
helper.forward = function(link,begin)
    local print = blank
    print(" forward",link,begin)
    if link.first == begin then return true end
end
helper.backward = function(link,begin)
    if link.second == begin then return true end
end
helper.any = function() return true end
helper.once = function()
    return function()

    end
end
helper.first = function(object)
    return function(link,direction)
        if link.first == object then return true end
    end
end
helper.second = function(object)
    return function(link,direction)
        if link.second == object then return true end
    end
end
--[[helper.any = function(...)
    local parts = {...}
    return function(link,direction)
        for _,part in pairs(parts) do
            local shouldBranch = true
            for _,branchCondition in pairs(part) do
                if not branchCondition(link,direction) then shouldBranch = false break end
            end
            if shouldBranch then return true end
        end
        return false
    end
end]]
helper.always = function() return true end
helper.never = function() return false  end
h=helper
FORWARDS = true
BACKWARDS = false
STOP = true

-- AMEND: optimise by only indexing the links of a specific by term from requirements, this means less irrelevant links need to be checked
-- e.g. find({h.by(std.is_a),...}...) will check object.links.next[0->2] despite specifying that anything other than std.is_a is blacklisted

-- a simple find function:
-- - takes a set of requirements
-- - tries to find a link for an object fitting these requirements
-- - if it does, call 'success' with the found object and return whatever it returns
-- - returns nil if it fails
find = function(requirements,...)
    local success = {...}
    return function(begin)
        if not begin then return nil end
        for by,group in pairs(begin.links) do
            for _,link in pairs(group) do
                local direction
                if link.first == begin then direction = FORWARDS end
                if link.second == begin then direction = BACKWARDS end
                local viable = true
                for _,requirement in pairs(requirements) do
                    if not requirement(link,begin) then viable = false break end
                end
                if viable then
                    local opposite
                    if link.first == begin then opposite = link.second else opposite = link.first end
                    for _,next in pairs(success) do
                        local result = next(opposite)
                        if result then
                            return result
                        end
                    end
                end
            end
        end
    end
end
finish = function(final) return final end
where = function(...) -- in a find manifest, 'skip' will return the object in the current layer, dropping the ones found in lower layers
    local success = {...}
    return function(begin)
        local viable = true
        for _,next in pairs(success) do
            local result = next(begin)
            if not result then viable = false break end
        end
        if viable then return begin else return nil end
    end
end
snitch = function(...)
    for _,thing in pairs({...}) do print(thing) end
    return nil
end
propagate = function(limit,requirements,...) -- a find function that is repeated
    local depth = 1
    local manifest
    local function callback(begin)
        if depth == limit then return nil end
        depth = depth + 1
        return manifest(begin)
    end
    manifest = find(requirements,...,callback)
    return manifest
end
return _G