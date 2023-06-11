--- Language Archive 1
--- Rewritten due to my sudden realisation of groups and lack of readability and maintainability

function get_group(word)
    local word_group
    find(word,
            {helper.by(std.inside),helper.forward(),helper.first(word)},
            {helper.by(std.is_a),helper.forward(),helper.second(group)},
            function(result,link) word_group = link.first return true end)
    return word_group
end

function get_entity(group)
    local entity_object
    find(group,
            {helper.never},
            {helper.by(std.repr),helper.forward(),helper.first(group)},
            function(result) entity_object = result return true end)
    return entity_object
end

function get_repr(word)
    local representative
    find(word,
            {helper.by(std.is_a),helper.forward()},
            {helper.by(std.repr),helper.forward()},
            function(result) representative = result return true end)
    return representative
end

function make_group()
    local new_group = object("(")
    local entity = object("")
    link(new_group,std.repr,entity)
    link(new_group,std.is_a,group)
    return new_group,entity
end

function make_link_phrase() -- otherwise known as a clause
end

function get_link_group(word)
    local new_link_group
    find(word,
            {helper.by(std.inside),helper.forward()},
            {helper.by(std.is_a),helper.forward(),helper.second(link_group)},
            function(result,link) new_link_group = link.first return true end)
    return new_link_group
end

words.hello = object("~'hello")
add(words.hello.acts,act(function(space)
    output("hello")
    -- evaluate: "you should say any greeting" by speaker0
end,"greeting.1"))

words.is = object("~'is")
link(words.is,std.repr,std.quality)
link(words.is,std.is_a,verb)
words.am = words.is
words.are = words.is

function verb_function(space)
    space.link_group = object("!LNKG")
    space.result_link = link(space.subject,std.is,space.object,ALLOW_UNKNOWN)
    link(space.result_link,std.because,space.link_group)
    link(space.link_group,std.is_a,link_group)
    link(space.source,std.inside,space.link_group)
    local function assign()
        output(space.subject.name..space.source.name.." "..space.object.name)
        space.result_link.first = space.subject or std.unknown
        space.result_link.second = space.object or std.unknown
        space.link_group:append(space.subject.name.." "..space.source.name.." "..space.object.name)
        space.operate()
    end
    task(space,function()
        space.previous = get_previous_word(space.source)
        if not space.previous then return RETRY end
        space.subject_group = get_group(space.previous)
        space.subject = get_entity(space.subject_group)
        find(space.subject,{helper.never},{helper.by(std.is_a),helper.forward(),helper.second(entity)},helper.result(space,"subject_is_entity"))
        link(space.subject_group,std.inside,space.link_group)
        if space.next then
            assign() return FINISH
        end
    end)
    task(space,function()
        space.next = get_next_word(space.source)
        if not space.next then return RETRY end
        space.object_group = get_group(space.next)
        space.object = get_entity(space.object_group)
        find(space.object,{helper.never},{helper.by(std.is_a),helper.forward(),helper.second(entity)},helper.result(space,"object_is_entity"))
        link(space.object_group,std.inside,space.link_group)
        if space.previous then
            assign() return FINISH
        end
    end)
end

to_be_action = act(function(space)
    function space.operate()
        link(space.subject,std.is,space.object) -- std.is doesn't mean 'subject is object', it means that they share qualities and are treated as equal/joined in searches
    end
    verb_function(space)
end)

add(words.is.acts,to_be_action)

proper_noun_act = act(function(space)
    space.previous = get_previous_word(space.source)
    space.group = get_group(space.previous)
    space.abstract = get_repr(space.source)
    function space.new_group()
        space.group,space.entity = make_group()
        link(space.entity,std.is_a,entity)
    end
    if not space.group then
        space.new_group()
    else
        space.entity = get_entity(space.group)
        find(space.entity,{helper.never},{helper.by(std.is_a),helper.forward(),helper.second(entity)},helper.result(space,"previous_is_entity"))
        if space.previous_is_entity then
            space.new_group()
        end
    end
    space.group:append(space.source.name)
    space.entity:append(space.source.name)
    link(space.entity,std.is,space.abstract)
    link(space.source,std.inside,space.group)
end)

words.you = object("~'you") -- hashtag
link(words.you,std.is_a,proper_noun)
link(words.you,std.repr,hashtag)

words.i = object("~'i") -- me
link(words.i,std.is_a,proper_noun)
link(words.i,std.repr,speaker0)

add(proper_noun.acts,proper_noun_act)

adjective_act = act(function(space)
    space.abstract = get_repr(space.source)
    if not space.abstract then return end
    space.previous = get_previous_word(space.source)
    space.group = get_group(space.previous)
    if not space.group then space.group = make_group() end
    link(space.source,std.inside,space.group)
    space.entity = get_entity(space.group)
    space.group:append(space.source.name)
    space.entity:append(space.source.name)
    if not space.entity then return end
    link(space.entity,std.quality,space.abstract)
end)

words.happy = object("~'happy")
link(words.happy,std.repr,happiness)
link(words.happy,std.is_a,adjective)

words.tasty = object("~'tasty")
link(words.tasty,std.repr,flavourful)
link(words.tasty,std.is_a,adjective)

words.good = object("~'good")
link(words.good,std.repr,std.good)
link(words.good,std.is_a,adjective)

words.sad = object("~'sad")
link(words.sad,std.repr,sadness)
link(words.sad,std.is_a,adjective)

add(adjective.acts,adjective_act)

words.eating = object("~'eating")
link(words.eating,std.repr,consumption)
link(words.eating,std.is_a,verb)

words.ate = object("~'ate")
link(words.ate,std.repr,consumption)
link(words.ate,std.is_a,verb)

words.what = object("~'what")
link(words.what,std.is_a,word)
act(function(space)

end)

noun_act = act(function(space)
    space.abstract = get_repr(space.source)
    if not space.abstract then return end
    space.previous = get_previous_word(space.source)
    space.group = get_group(space.previous)
    if not space.group then space.group = make_group(space.group) end
    link(space.source,std.inside,space.group)
    space.entity = get_entity(space.group)
    space.group:append(space.source.name)
    space.entity:append(space.source.name)
    if not space.entity then return end
    link(space.entity,std.is_a,space.abstract)
end)

words.cookie = object("~'cookie")
link(words.cookie,std.repr,cookie)
link(words.cookie,std.is_a,class_noun)

words.snack = object("~'food")
link(words.snack,std.repr,consumable)
link(words.snack,std.is_a,class_noun)

add(class_noun.acts,noun_act)

words.a = object("~a")
add(words.a.acts,act(function(space)
    space.group,space.entity = make_group()
    space.group:append("det_inst")
    space.entity:append("det_inst")
    link(space.entity,std.is_a,entity)
    link(space.source,std.inside,space.group)
end))

today = object("!~today")

time_act = act(function(space)
    space.abstract = get_repr(space.source) -- current time... but how?
    if not space.abstract then return end
    space.previous = get_previous_word(space.source)
    space.group = get_group(space.previous)
    if not space.group then space.group = make_group(space.group) end
    link(space.source,std.inside,space.group)
    space.entity = get_entity(space.group)
    if not space.entity then return end
    link(space.entity,std.is_a,space.abstract)
end)

words.today = object("~today")
add(words.today.acts,act(function(space)
    -- add at to verb (adverb)
    -- make itself an object
    local function assign()
        find(space.group,
                {helper.never},
                {helper.by(std.because),helper.backward()},
                function(next) link(next,std.at,space.abstract) return true end)
    end
    space.abstract = get_repr(space.source)
    if not space.abstract then return end
    task(space,function()
        space.previous = get_previous_word(space.source)
        space.group = get_link_group(space.previous)
        if space.group then assign() return FINISH end
        space.next = get_next_word(space.source)
        space.group = get_link_group(space.next)
        if space.group then assign() return FINISH end
        return RETRY
    end)
end))
link(words.today,std.repr,today)
link(words.today,std.is_a,time_word)
