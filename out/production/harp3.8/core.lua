--- HARP 3.8 @ 08/04/2023 by Christian Lincoln in Lua

--- RULES:
--- O-L-A Cortex /w ShortMemory
--- ^:descriptor !:instance ~:class
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
    add(this[term],data)
end
output = function(string) print("#: "..string) end

_link = {}
_link.__index = _link
_link.__tostring = function(this) return "LNK("..this.first.name.." -> "..this.by.name.." -> "..this.second.name..")" end
link = function(first,by,second)
    if not first then error("First Missing") end
    if not by then error("By Missing") end
    if not second then error("Second Missing") end
    local new = {}
    new.first = first
    new.by = by
    new.second = second
    new.meta = {} -- indexed by a by-term to provide metadata
    new.pressure = 1 -- for numerical links (against by term)
    setmetatable(new,_link)
    -- assuming new.meta.^cause is empty, this link is absolutely true
    relate(new.meta,std.at,os.time())
    relate(new.first.links,by,new)
    relate(new.second.links,by,new)
    return new
end
_object = {}
_object.__tostring = function(this) return "OBJ("..this.name..")" end
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
task = function(space,callback)
    local new = {}
    new.callback = callback
    new.space = space
    add(tasks,new)
    return new
end
aware = act(function(space) -- it is unknown how 'awareness' in a cortex works, this is a supplement for the behaviour
    local classes = space.trigger.links[std.is_a]
    if classes then
        for _,link in pairs(classes) do
            if link.first == space.trigger then
                for _,act in pairs(link.second.acts) do
                    act.run({source=space.source,trigger=link.second})
                end
            end
        end
    end
end,"aware")