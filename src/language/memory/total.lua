revision = object("~revision"):where(std.quality,performance)
verb_combo(revision,
        "revised",
        "revising",
        "revise",
        "revision"
)
eating = object("~eating"):where(std.quality,performance)
verb_combo(eating,
        "ate",
        "eating",
        "eat",
        "consumption"
)
going = object("~going"):where(std.quality,performance)
verb_combo(going,
        "went",
        "going",
        "go",
        "moving"
)
sleeping = object("~sleeping"):where(std.quality,performance)
verb_combo(sleeping,
        "slept",
        "sleeping",
        "sleep",
        ""
)
cookie = object("~cookie"):where(std.quality,consumable)
noun_combo(cookie,
        "cookie",
        "cookies"
)
place = object("~place") -- LNK for:
-- expect: LNK(LNK(anything,perf,going),to,place) where LNK(anything,quality,person) and LNK(event,time,any/expect)
restaurant = object("~restaurant"):where(std.quality,place)
-- expect: LNK(LNK(anything,perf,eating),in,place|to,food) where LNK(anything,quality,human) and LNK(event,time,any/expect)
-- how would these expectations be described and used to make assumptions/interrogations?
-- when somebody goes to a restaurant, they usually eat good
good = std.good
noun_combo(place,
        "place"
)
noun_combo(restaurant,
        "restaurant"
)
adjective_combo(good,
        "goodness",
        "good"
)

speaker0 = object("!speaker0"):where(std.is_a,real_object)
proper_combo(speaker0,
        "i" -- note, an action for 'i' should be made so that it refers to the causation of the text, not like a name for speaker0
)

home = object("!home"):where(std.is_a,real_object)
proper_combo(home,
        "home"
)

simple_word("who")
simple_word("what")
simple_word("a")


response = {}
response.acknowledge = act(function(space)
    output("ok")
end)
response.confirm = act(function(space)
    output("yes")
end)
response.negate = act(function(space)
    output("no")
end)
response.unknown = act(function(space)
    output("not sure")
end)

--[[ Actions in language will not follow standard english grammatical rules as with previous archives.
 Abstraction is important to facilitate truly effective communication, for example, what if I missed out a word or didn't understand english well?
 Therefore, all actions in my third language model will operate under the premise that this system is communicating with a developing child

-- Subject: find({h.by(s.inside),h.forward),find({h.by(s.inside),h.backward},find({h.by(s.repr),h.forward},finish)))(space.source)


-- Note: saying 'good dog' and 'dog good' are equal in meaning, but one of the words founds the object before another, the other simply hitches a ride.
--[[ Simple Verb Action:
A simple verb can be considered as any verb that does not have any special exceptions or rules associated with it.
In this project, the sentence 'I ate the cookie' would be interpreted as a link stating that the subject performs the verb;
the resultant link from the sentence would also have additional linked values stating that this happened in the past tense towards the cookie.
]]




-- Past Tense, states that the resultant link occurred at a previous event


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
--[[ A Article Action:
Articles appear to create objects and look for them.
]]
add(words.a.acts,act(function(space)
    space.object = object("!"):where(std.is_a,real_object)
    link(space.source,std.repr,space.object)
end))
--[[ Who Sacrificial Action:
It appears that 'who' also seems to work as a sacrificial delegate for the subject of the sentence in performance assignment (verbs).
]]
add(words.who.acts,act(function(space)
    task(space,function(space)
        space.subject = propagate(shenanigans)
        link(space.source,std.repr,space.subject)
    end)
end))
--[[ Who Interrogatory Action: ]]
--[[ What Interrogatory Action: ]] -- what ate it, what is that, what him, what did it eat
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
add(preposition,act(function(space)
    space.repr = isRepresentative(finish)(space.space.source)
    task(space,function(space)

    end)
end))
--[[ Time Phrase Action:

]]
simple_word("today")
add(words.today.acts,act(function(space)
    task(space,function(space)
        space.verb = nearWord(3,h.any,isVerbWord)(space.source)
        space.verb = isRepresentative(finish)(space.verb)
        if not space.verb then return RETRY end
        link(space.verb,std.at,today)
    end)
end))


task({},function(space)
    -- ok so loopback through recent time... has anything happened? no, so ask how am i... init...
end)


-- i am going to the boarding house
-- i was going to the boarding house

-- what are you doing?
-- how are you?