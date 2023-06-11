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

--[[ A Article Action:
Articles appear to create objects and look for them.
]]
simple_word("a")
add(words.a.acts,act(function(space)
    space.object = object("!"):where(std.is_a,real_object)
    link(space.source,std.repr,space.object)
end))
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