add(acting_verb.acts,act(function(space)
    space.text = isInsideAText(space.source)
    if not space.text then return FINISH end
    space.repr = abstract(isRepresentative(finish))(space.source)
    task(space,function(space)
        -- find the subject of the sentence previously
        space.subject_word = nearWord(10,h.backward,isNounWord)(space.source)-- AMEND: qualification!
        space.subject = isRepresentative(finish)(space.subject_word)
        if not space.subject then return RETRY end
        space.result = link(space.subject,std.perform,space.repr) --- Interrogation or Confirmation could be ran here!
        link(space.source,std.repr,space.result)
    end)
    task(space,function(space)
        if space.object then return FINISH end
        -- find the object of the sentence afterwards
        space.object_word = nearWord(3,h.forward,isNounWord)(space.source)
        space.object = isRepresentative(finish)(space.object_word)
        if not space.object then return RETRY end
    end)
    task(space,function(space) -- alternatively check if its behind the subject...
        if space.object then return FINISH end
        if not space.subject_word then return RETRY end
        space.object_word = nearWord(3,h.backward,isNounWord)(space.subject_word)
        space.object = isRepresentative(finish)(space.object_word)
        if not space.object then return RETRY end
    end)
    task(space,function(space)
        -- wait for subject and object
        if not space.result or not space.object then return RETRY end
        link(space.result,std.towards,space.object) --- Interrogation or Confirmation could be ran here too!
    end)
end))