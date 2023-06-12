_G = require("helper")

--- Human Memory:
--- Performance (What things do to each other)
--- Organisation (Rules that relate things to each other)
--- Quality (Things that things have about each other)

std = {} -- literal standards for defining the world, akin to constants

--- Qualities/Relational
std.quality = object("^quality") -- abstract standard describing the world
std.is_a = std.quality -- object("^is_a") -- RIP
std.is = std.quality -- object("^is") -- RIP
std.next = object("^next") -- to be replaced with positional relativity (numerical links) (or possibly .pressure)
std.after = object("^after") -- std.next but for time
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
std.towards = object("^towards")

std.same = object("^similarity") -- stating that two objects are similar (numeric)
std.origin = object("^origin")

std.unknown = object("~unknown")
std.any = object("^anything")
s=std

--- Classes/Objects
std.event = object("~time_event")
std.current_time = object("!@"..os.time().."init")
std.time = function()
    local time = object("!@"..os.time())
    link(time,std.after,std.current_time)
    return time
end
std.sleep = function() -- forget all your troubles, clear hanging tasks
    tasks = {}
end
std.aware = act(function(space) -- it is unknown how 'awareness' in a system works, this is a supplement for the behaviour
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

return _G