--[[ Who Sacrificial Action:
It appears that 'who' also seems to work as a sacrificial delegate for the subject of the sentence in performance assignment (verbs).
]]
simple_word("who")
add(words.who.acts,act(function(space)
    task(space,function(space)
        space.subject = propagate(shenanigans)
        link(space.source,std.repr,space.subject)
    end)
end))
--[[ Who Interrogatory Action: ]]
--[[ What Interrogatory Action: ]] -- what ate it, what is that, what him, what did it eat
simple_word("what")
add(words.what.acts,act(function(space)
    task(space,function(space)
        if not space.verb or not space.subject then return RETRY end
        abstract(find({h.by(std.perform),h.second(space.verb)},finish))(space.subject) -- find from the subject what it did that was the verb
    end)
    task(space,function(space)
        space.verb = nearWord(3,h.forward,isVerbWord)(space.source)
        space.verb = isRepresentative(finish)(space.verb)
        if not space.verb then return RETRY end
    end)
    task(space,function(space)
        space.subject = nearWord(5,h.forward,isNounWord)(space.source)
        space.subject = isRepresentative(finish)(space.subject)
        if not space.subject then return RETRY end
    end)
    task(space,function(space)
        -- auxiliary
    end)
end))
-- WHAT IS SUB INF (subject present performance)
-- WHAT IS SUB (subject quality)
-- WHAT DID SUB INF (subject past performance)
-- WHAT WILL SUB INF (subject future performance)
-- WHAT HAS SUB PAST (past performance) (VERB)
-- WHAT PAST OBJECT (object past performance)
-- WHAT WILL VERB
--[[ Preposition Action:
A preposition simply sets the by term of a linked link (an adverb type language.construct). They make a verb structure polyvalent
I went to your house at 3 o'clock: LNK(LNK(i->perf->go)->at->!@)
I went with Tommy: LNK(LNK(i->perf->go)->with->tommy) (not done yet, for this preposition inference is critical) LNK(LNK(tommy->perf->go)->cause->...)]]
