quality_verb = object("~quality_verb")
add(quality_verb.acts,act(function(space)
    print("pp")
    space.text = isInsideAText(space.source)
    if not space.text then return FINISH end
    task(space,function(space)
        -- find the subject of the sentence previously
        space.subject_word = nearWord(10,h.backward,isNounWord)(space.source)-- AMEND: qualification!
        space.subject = isRepresentative(finish)(space.subject_word)
        if not space.subject then return RETRY end --- Interrogation or Confirmation could be ran here!
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
        if not space.subject or not space.object then return RETRY end
        space.result = link(space.subject,std.quality,space.object) --- Interrogation or Confirmation could be ran here too!
        link(space.source,std.repr,space.result)
    end)
end))

-- here I have disregarded how RMs expect specific verbs to be used in certain situations: e.g. "I am happy"; "It am happy"
simple_word("is"):where(std.is_a,verb):where(std.is_a,present_verb):where(std.is_a,quality_verb)
simple_word("am"):where(std.is_a,verb):where(std.is_a,present_verb):where(std.is_a,quality_verb)
simple_word("are"):where(std.is_a,verb):where(std.is_a,present_verb):where(std.is_a,quality_verb)
simple_word("was"):where(std.is_a,verb):where(std.is_a,past_verb):where(std.is_a,quality_verb)
simple_word("were"):where(std.is_a,verb):where(std.is_a,past_verb):where(std.is_a,quality_verb)