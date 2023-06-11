--[[ Simple Verb Action:
A simple verb can be considered as any verb that does not have any special exceptions or rules associated with it.
In this project, the sentence 'I ate the cookie' would be interpreted as a link stating that the subject performs the verb;
the resultant link from the sentence would also have additional linked values stating that this happened in the past tense towards the cookie.
]]

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

add(infinite_verb.acts,act(function(space)
    -- look for 'I am revising'
    space.text = isInsideAText(space.source)
    if not space.text then return FINISH end
    space.repr = abstract(isRepresentative(finish))(space.source)
    if not space.repr then return FINISH end
    space.blank = object("_!"):where(std.is_a,real_object):where(std.quality,std.any) -- or whatever the thing that normally does space.repr is (barking: dog)
    space.result = link(space.blank,std.perform,space.repr)
    link(space.source,std.repr,space.blank) -- an infinitive represents something doing something in essence, this represents the first something
end))