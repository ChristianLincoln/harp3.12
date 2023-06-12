add(past_verb.acts,act(function(space)
    space.text = isInsideAText(space.source)
    if not space.text then return FINISH end
    task(space,function(space)
        -- find resultant link from this verb, (space.source -> repr -> space.result)
        space.result = isRepresentative(finish)(space.source)
        if not space.result then return RETRY end
        space.event = object("!@past") -- or propagate to find a time in context
        link(std.time(),std.after,space.event)
        link(space.result,std.at,space.event)
    end)
end))
add(present_verb.acts,act(function(space)
    space.text = isInsideAText(space.source)
    if not space.text then return FINISH end
    task(space,function(space)
        space.result = isRepresentative(finish)(space.source)
        if not space.result then return RETRY end
        space.event = std.time()
        link(space.result,std.at,space.event)
    end)
end))
add(stative_verb.acts,act(function(space)
    space.text = isInsideAText(space.source)
    if not space.text then return FINISH end
    task(space,function(space)
        -- find resultant link from this verb, (space.source -> repr -> space.result)
        space.result = isRepresentative(finish)(space.source)
        if not space.result then return RETRY end
        space.event = object("!@past") -- or propagate to find a time in context
        link(space.event,std.after,std.time())
        link(space.result,std.at,space.event)
    end)
end))