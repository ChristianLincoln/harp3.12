--- HARP 3.8 @ 08/04/2023 by Christian Lincoln in Lua

--- RULES:
--- O-L-A Cortex /w ShortMemory
--- ^:language.memory.descriptor !:instance ~:class
--- No recognition needed, auto-words
--- Awareness action used for linked acts
--- Links are open to interpretation

--- PROPOSITIONS:
--- Links use by-term as index to object link store, as respect is given to by-term as constant
--- Link meta-data is stored in the link itself rather than link to a link as though link was an object
--- The potential for comparing real data such as time and position by a complementary term e.g. left,right,after,before

--- AIMS:
--- Working Language: Describing new words, events and respecting speakers.
---     -- Success: Highly Basic SVO Clause Structure
--- Links: Understanding meta-links.
--- Links: Understanding real data comparisons for use in time and recognition.
blank = function()  end
add = table.insert
relate = function(this,term,data)
    if not this[term] then this[term] = {} end
    add(this[term],1,data)
end
output = function(string) print("#:  "..string) end

_link = {}
_link.about = function(this) print(this) for byTerm,links in pairs(this.links) do for _,link in pairs(links) do print(" "..tostring(link)) end end end
_link.__index = _link
_link.__tostring = function(this) return "LNK("..this.first.name.." -> "..this.by.name.." -> "..this.second.name..")" end
ALLOW_UNKNOWN = true
link = function(first,by,second,pressure)
    if not flags then
        if not first then error("First Missing") end
        if not second then error("Second Missing") end
    end
    if not by then error("By Missing") end
    local new = {}
    new.first = first or std.unknown
    new.by = by
    new.second = second or std.unknown
    new.name = "LNK"
    if getmetatable(new.first) == _object and getmetatable(new.second) == _object then
        new.links = {} -- indexed by a by-term to provide metadata
        --link(new,std.at,os.time())
    end
    new.pressure = pressure or 1 -- for numerical links (against by term)
    setmetatable(new,_link)
    -- assuming new.meta.^cause is empty, this link is absolutely true
    relate(new.first.links,by,new)
    relate(new.second.links,by,new)
    if getmetatable(new.second) == _object then for _,action in pairs(new.second.acts) do -- awareness?
        action.run({source=new.first,trigger=new.second})
    end end
    return new
end
_object = {}
_object.__index = _object
_object.__tostring = function(this) return "OBJ("..this.name..")" end
_object.append = function(this,string) this.name = this.name .. string  end
_object.where = function(this,by,to) link(this,by,to) return this  end
_object.about = function(this) print(this) for byTerm,links in pairs(this.links) do for _,link in pairs(links) do print(" "..tostring(link)) end end end
object = function(name)
    local new = {}
    new.links = {}
    new.acts = {}
    new.name = name
    return setmetatable(new,_object)
end
_act = {}
act = function(run,name)
    local new = {}
    new.run = run
    new.name = name
    return setmetatable(new,_act)
end
RETRY = true
FINISH = false
_task = {}
tasks = {}
task = function(space,callback)
    local new = {}
    new.callback = callback
    new.space = space
    add(tasks,new)
    return new
end
short={}
return _G