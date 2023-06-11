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
ALLOW_UNKNOWN = true
link = function(first,by,second,flags)
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
    new.pressure = 1 -- for numerical links (against by term)
    setmetatable(new,_link)
    -- assuming new.meta.^cause is empty, this link is absolutely true
    relate(new.first.links,by,new)
    relate(new.second.links,by,new)
    for _,action in pairs(new.second.acts) do -- awareness?
        action.run({source=new.first,trigger=new.second})
    end
    return new
end
_object = {}
_object.__index = _object
_object.__tostring = function(this) return "OBJ("..this.name..")" end
_object.append = function(this,string) this.name = this.name .. string .. " "  end
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
helper.forward = function()
    return function(link,direction)
        local print = blank
        print(" forward",link,direction)
        if direction == FORWARDS then return true end
    end
end
helper.backward = function()
    return function(link,direction)
        if direction == BACKWARDS then return true end
    end
end
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
helper.any = function(...)
    local parts = {...}
    return function(link,direction)
        for _,part in pairs(parts) do
            local shouldBranch = true
            for _,branchCondition in pairs(part) do
                if not branchCondition(link.link,link.direction) then shouldBranch = false break end
            end
            if shouldBranch then return true end
        end
        return false
    end
end
helper.always = function() return true end
helper.never = function() return false  end
h=helper
FORWARDS = true
BACKWARDS = false
STOP = true
find = function(begin,branch,success,result)
    if not begin then return false end
    local print = blank
    local addPotential = function(links,new)
        print("adding")
        for byTermName,linkGroup in pairs(new.links) do for _,link in pairs(linkGroup) do
            if link.first == new and link.second ~= new then
                print(link)
                add(links,{link=link,direction=FORWARDS})
            elseif link.second == new and link.first ~= new then
                print(link)
                add(links,{link=link,direction=BACKWARDS})
            end
        end end
        print()
    end
    local potentialLinks = {}

    local nextLinks = {}
    addPotential(potentialLinks,begin)
    local depthTrigger = 2

    while #potentialLinks >= 1 do
        print(depthTrigger)
        if depthTrigger < 0 then error("Depth limit reached on find...") end
        depthTrigger = depthTrigger - 1
        for _,link in pairs(potentialLinks) do print(link.link,link.direction) end
        print()
        for _,link in pairs(potentialLinks) do
            print(link.link)
            local nextNode
            if link.direction == FORWARDS then nextNode = link.link.second
            elseif link.direction == BACKWARDS then nextNode = link.link.first end

            print("success?")
            local wasSuccess = true
            for _,successCondition in pairs(success) do
                if not successCondition(link.link,link.direction) then wasSuccess = false break end
            end
            if wasSuccess then print(" result",nextNode) if result(nextNode,link.link) then return end end

            print("branch?")
            local shouldBranch = true
            for _,branchCondition in pairs(branch) do
                if not branchCondition(link.link,link.direction) then shouldBranch = false break end
            end
            if shouldBranch then print(" branching") addPotential(nextLinks,nextNode) end
            print()
        end
        potentialLinks = nextLinks
        nextLinks = {}
    end
end

short = {}
std = {}
tasks = {}

--- Human Memory:
--- Performance (What things do to each other)
--- Organisation (Rules that relate things to each other)
--- Quality (Things that things have about each other)

wordClass = object("~word")
words = {} -- supplementary for recognition

std.is_a = object("^is_a") -- literal standards for defining the world
std.is = object("^is")
std.next = object("^next") -- to be replaced with positional relativity (numerical links)
std.at = object("^time")
std.repr = object("^represent") -- delegatory
std.good = object("^good") -- (numeric)
std.bad = object("^bad")
--[[add(std.bad.acts,act(function(space)
    -- get relating information
    -- find cause
    -- counter?
    find(space.source,{helper.never},{})
end))]]
std.because = object("^causation") -- how is because and causes different
std.causes = object("^results")
std.inside = object("^inside")
std.perform = object("^perform")

std.same = object("^similarity") -- stating that two objects are similar (numeric)
std.quality = object("^quality") -- abstract standard describing the world
std.origin = object("^origin")

std.unknown = object("~unknown")
s=std

function main()
    for _,word in pairs(words) do if not word.acts.aware then word.acts["aware"] = aware end end -- make cortex aware of how it should respond to each word because of what it is
    while true do
        io.write("P: ")
        io.flush()
        local input = io.read().." "
        if input == "end" then break end
        local word = ""
        local previous
        local speech = object("!speech")
        link(speech,std.because,speaker0) -- speaker0 always makes speech
        for index=1,#input,1 do
            local char = string.sub(input,index,index)
            if char == " " then
                local class = words[word]
                if not class then
                    words[word] = object()
                    class = words[word]
                end
                word = object("!"..word)
                if previous then link(previous,std.next,word) end
                link(word,std.is_a,class)
                --link(word,std.inside,speech)
                --add(word.acts,aware)
                table.insert(short,1,word)
                newTasks = {}
                for _,task in pairs(tasks) do
                    if task.callback(word) == RETRY then
                        add(newTasks,task)
                    end
                end
                tasks = newTasks
                previous = word
                word = ""
            else
                word = word .. char
            end
        end
    end
end

return _G