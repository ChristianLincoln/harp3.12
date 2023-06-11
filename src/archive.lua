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

simple_word("a")
add(words.a.acts,act(function(space)
    space.group,space.entity = make_group()
    space.group:append("det_inst")
    space.entity:append("det_inst")
    link(space.entity,std.is_a,entity)
    link(space.source,std.inside,space.group)
end))

simple_word("today")
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

--- Language Archive 2
--- Rewritten since I realised that strict actions for all language features is silly, recognition manifests for individual language constructs is more naturalistic

function object_descriptor(space,type)
    if not get_text(space.source) then return end
    space.word_repr = get_representative(space.source)
    space.clause,space.link = get_clause(space.source)
    if not space.clause then space.clause,space.link = make_clause() end
    space.group,space.group_repr = get_current_object_group(space.source)
    if not space.group then space.group,space.group_repr = make_object_group() link(space.group,std.inside,space.clause) end
    space.clause:append(space.source.name)
    space.group:append(space.source.name)
    space.group_repr:append(space.source.name)
    link(space.group_repr,type,space.word_repr,ALLOW_UNKNOWN)
    link(space.source,std.inside,space.group,ALLOW_UNKNOWN)
end
add(proper_noun.acts,act(function(space)
    object_descriptor(space,std.is)
end))
add(class_noun.acts,act(function(space)
    object_descriptor(space,std.is_a)
end))
add(adjective.acts,act(function(space)
    object_descriptor(space,std.quality)
end))
add(time_phrase.acts,act(function(space)
    if not get_text(space.source) then return end
    space.word_repr = get_representative(space.source)
    space.clause,space.link = get_clause(space.source)
    if not space.clause then space.clause,space.link = make_clause() end
    link(space.source,std.inside,space.clause)
    task(space,function()
        space.clause_link = get_clause_link(space.clause)
        if space.clause_link then
            link(space.clause_link,std.at,space.word_repr)
            return FINISH
        end
        return RETRY
    end)
end))
add(simple_verb.acts,act(function(space)
    if not get_text(space.source) then return end
    space.word_repr = get_representative(space.source)
    space.clause,space.link = get_clause(space.source)
    if not space.clause then space.clause,space.link = make_clause() end
    space.clause:append(space.source.name)
    space.clause_link = link(nil,perform,space.word_repr,ALLOW_UNKNOWN)
    link(space.clause,std.repr,space.clause_link)
    task(space,function()
        space.clause_subject = get_object_group(get_previous_word(space.source))
        if space.clause_subject then
            link(space.clause_subject,std.is_a,subject)
            return FINISH
        end return RETRY
    end)
    task(space,function()
        space.clause_object = get_object_group(get_previous_word())
    end)
    --[[task(space,function() -- get the clause subject
        space.clause_subject = get_object_group(get_previous_word(space.source)) or get_object_group(get_next_word(space.source))
        if space.clause_subject then
            link(space.clause_subject,std.is_a,subject)
            return FINISH end
        return RETRY end)
    task(space,function() -- clause subject is reliant on clause object
        if space.clause_subject then
            space.clause_target = get_target(space.clause)
            link(space.clause_target,std.is_a,target)
            return FINISH end
        return RETRY end)
    task(space,function() -- apply clause subject
        if space.clause_subject then space.clause_link.first = get_representative(space.clause_subject)
            return FINISH end
        return RETRY end)
    task(space,function() -- apply clause target
        local preposition = get_preposition(space.clause_target)
        if space.clause_target and space.clause_link and not preposition then link(space.clause_link,valency,get_representative(space.clause_target))
            return FINISH end
        return RETRY end)]]
    link(space.source,std.inside,space.clause)
end))
add(stative_verb.acts,act(function(space)
    if not get_text(space.source) then return end
    task(space,function()
        space.clause,space.link = get_clause(space.source)
        if space.link then
            link(space.link,std.at,expect)
            return FINISH
        end
        return RETRY
    end)
end))
add(past_participle.acts,act(function(space)
    if not get_text(space.source) then return end
    task(space,function()
        local time = object("!@past")
        link(time,std.after,make_time_marker())
        space.clause,space.link = get_clause(space.source)
        if space.link then
            link(space.link,std.at,time)
            return FINISH
        end
        return RETRY
    end)
end))
add(preposition.acts,act(function(space)
    if not get_text(space.source) then return end
    space.clause,space.link = get_clause(space.source)
    if not space.clause then space.clause,space.link = make_clause() end
    space.clause:append(space.source.name)
    space.repr = get_representative(space.source)
    link(space.source,std.inside,space.clause)
    task(space,function()
        space.clause,space.link = get_clause(space.source)
        if space.link and space.group then
            local object = get_representative(space.group)
            link(space.link,space.repr,object)
            return FINISH
        end
        return RETRY
    end)
    task(space,function()
        space.next = get_next_word(space.source)
        space.group = get_object_group(space.next)
        if space.group then
            link(space.source,std.inside,space.group)
            space.group:append(space.source.name)
            return FINISH
        end
        return RETRY
    end)
end))

--- Language Archive 2
--- The find functions used to traverse short memory

function get_previous_word(current_word)
    local previous_word
    find(current_word,
            {helper.never},
            {helper.by(std.next),helper.backward(),helper.second(current_word)},
            function(result) previous_word = result return STOP end)
    return previous_word
end

function get_next_word(current_word)
    local next_word
    find(current_word,
            {helper.never},
            {helper.by(std.next),helper.forward(),helper.first(current_word)},
            function(result) next_word = result return STOP end)
    return next_word
end

function get_current_object_group(current_word)
    local previous = get_previous_word(current_word)
    return get_object_group(previous)
end

function get_object_group(current_word)
    local group
    find(current_word,
            {helper.by(std.inside),helper.forward(),helper.first(current_word)},
            {helper.by(std.is_a),helper.forward(),helper.second(object_group)},
            function(result,link) group = link.first return STOP end)
    local representative = get_representative(group)
    return group,representative
end

function get_current_clause(current_word)
    local previous = get_previous_word(current_word)
    return get_clause(previous)
end

function get_clause(current_word)
    local previous = get_previous_word(current_word)
    local return_clause
    local return_link
    find(previous,
            {helper.by(std.inside),helper.forward()},
            {helper.by(std.is_a),helper.forward(),helper.second(clause)},
            function(result,link) return_clause = link.first return STOP end)
    find(return_clause,
            {helper.never},
            {helper.by(std.repr),helper.forward(),helper.first(return_clause)},
            function(result,link) return_link = link.second return STOP end)
    return return_clause,return_link
end

function make_clause()
    local clause = object(">[]"):where(std.is_a,clause)
    local clause_link
    return clause,clause_link
end

function get_subject(current_clause)
    local return_subject
    find(current_clause,
            {helper.by(std.inside),helper.backward(),helper.second(current_clause)},
            {helper.by(std.is_a),helper.forward(),helper.second(subject)},
            function(result,link) return_subject = link.first return STOP end
    )
    return return_subject
end

function get_target(current_clause)
    local return_target
    find(current_clause,
            {helper.by(std.inside),helper.backward(),helper.second(current_clause)},
            {helper.by(std.is_a),helper.forward(),helper.second(object_group)},
            function(result,link)
                local isSubject = false -- dirty, AMEND find functions
                find(link.first,
                        {helper.never},{helper.by(std.is_a),helper.forward(),helper.second(subject)},
                        function() isSubject = true return STOP end)
                if not isSubject then
                    return_target = link.first
                    return STOP
                end
            end
    )
    return return_target
end

function get_representative(current_group)
    local representative
    find(current_group,
            {helper.by(std.is_a),helper.forward()},
            {helper.by(std.repr),helper.forward()},
            function(result,link) representative = result return STOP end)
    return representative
end

function get_preposition(current_group)
    local prep
    find(current_group,
            {helper.by(std.inside),helper.backward(),helper.second(current_group)},
            {function(link)
                local res
                find(link.first,
                        {h.by(std.is_a),h.forward()},
                        {h.by(std.is_a),h.forward(),h.second(preposition)},
                        function(result,link) res = link.first return STOP end)
                return res
            end},
            function(result,link) prep = link.first return STOP end)
    return prep
end

function get_clause_link(current_clause)
    local clause_link
    find(current_clause,
            {helper.never},
            {helper.by(std.repr),helper.forward(),helper.first(current_clause)},
            function(result,link) clause_link = link.second return STOP end)
    return clause_link
end

function make_object_group()
    local group = object("![]")
    local representative = object("!")
    link(group,std.is_a,object_group)
    link(group,std.repr,representative)
    return group,representative
end

function get_text(current_word)
    local speech
    find(current_word,
            {helper.by(std.inside),helper.forward()},
            {helper.by(std.inside),helper.forward(),helper.second(text)},
    function(result) speech = result return STOP end)
    return speech
end

function get_previous_object_group(current_word)
    local previous
    find(current_word,
            {helper.by(std.next),helper.backward()},
            {helper.by(std.is_a),helper.forward(),helper.second(object_group)},
            function(result)  end)
end

--- Architecture Archive 1
--- Archiving this since I realised find functions aren't just 'branch' and 'success', they have layers of requirements

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
            if wasSuccess then print(" result",nextNode) if result(nextNode,link.link) then return true end end

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

--- Language Archive 3
--- No archive here except for std.is_a because I believe that it should now be completely replaced with the abstract term std.quality
--- For the sake of my own conscious, whenever std.quality is used against a real_object class rather than a language.memory.descriptor I will use std.is_a

std.is_a = object("~is_a")

--- Language Archive 4
--- Scrapping all current recognition manifests and actions against language since I believe that I need to refresh my thought process
--- Current methods are way to systematic, more abstraction is clearly required for this system to comprehend English effectively
--[[ Despite this, this acting series was highly successful,
I have never been able to ask a HME whether I have performed a task or that I am something so cleanly
Furthermore, this HME showed me so many different things in memory, as to why Archive 3 exists
]]

words.hello = object("~'hello")
words.goodbye = object("~'goodbye")
words.a = object("~'a")
words.the = object("~'the")
words.is = object("~'is"):where(std.is_a,present_verb)
words.am = words.is
words.are = words.is
words.that = object("~'that")
words.you = object("~'you"):where(std.is_a,proper_noun):where(std.repr,hashtag)
words.i = object("~'i"):where(std.is_a,proper_noun):where(std.repr,speaker0)
words.hurl = object("~'about")
words.happy = object("~'happy"):where(std.is_a,adjective):where(std.repr,happiness)
words.sad = object("~'sad"):where(std.is_a,adjective):where(std.repr,sadness)
words.tasty = object("~'tasty"):where(std.is_a,adjective):where(std.repr,flavourful)
words.good = object("~'good"):where(std.is_a,adjective):where(std.repr,std.good)
words.bad = object("~'bad"):where(std.is_a,adjective):where(std.repr,std.bad)
words.eating = object("~'eating")
words.eat = object("~'eat"):where(std.is_a,simple_verb):where(std.repr,consumption):where(std.is_a,stative_verb)
words.eats = object("~'eats"):where(std.is_a,simple_verb):where(std.repr,consumption):where(std.is_a,stative_verb)
words.what = object("~'what")
words.today = object("~'today"):where(std.is_a,time_phrase):where(std.repr,today)
--words.cookie = object("~'cookie"):where(std.is_a,class_noun):where(std.repr,cookie)
words.store = object("~'store"):where(std.is_a,class_noun):where(std.repr,store)
words.say = object("~'say"):where(std.is_a,simple_verb):where(std.repr,speaking)
words.house = object("~'house"):where(std.is_a,class_noun)
words.human = object("~'human"):where(std.is_a,class_noun):where(std.repr,human)
words.dorm = object("~'dorm"):where(std.is_a,class_noun)
words.to = object("~'to"):where(std.is_a,preposition):where(std.repr,towards)
words.with = object("~'with"):where(std.is_a,preposition):where(std.repr,alongside)
words.went = object("~'went"):where(std.is_a,simple_verb):where(std.repr,coming):where(std.is_a,past_participle)
words.ate = object("~'ate"):where(std.is_a,simple_verb):where(std.repr,consumption):where(std.is_a,past_participle)
words.eat = object("~'eat"):where(std.is_a,simple_verb):where(std.repr,consumption)
words["do"] = object("~'do"):where(std.is_a,simple_verb):where(std.repr,perform)
words.did = object("~'did"):where(std.is_a,simple_verb):where(std.repr,perform):where(std.is_a,past_participle)
words.what = object("~'what"):where(std.is_a,interrogatory)
words.is = object("~'(is)"):where(std.repr,std.quality)
words.now = object("~now"):where(std.is_a,time_phrase)
words.am = words.is
words.are = words.is
words.was = object("~'(was)"):where(std.is_a,simple_verb):where(std.repr,std.quality):where(std.is_a,past_participle)
words.were = words.was
words.sleep = object("~'sleep"):where(std.is_a,simple_verb):where(std.repr,sleeping)

local commonDescriptorAct = function(type) return act(function(space)
    if not isInsideAText(space.source) then return end
    space.representative = abstract(find({h.by(std.repr),h.forward},finish))(space.source)
    task(space,function(space)
        space.object = find({h.by(std.next),h.backward},
                find({h.by(std.repr),h.forward},
                        where(find({h.by(std.is_a),h.second(type)},finish))
                )
        )(space.source)
        if not space.object then return RETRY end
        link(space.object,std.quality,space.representative)
        link(space.source,std.repr,space.object)
        space.object.name = space.object.name..space.source.name
    end)
end) end
add(words.am.acts,act(function(space) -- RM(entity_representative >> source(am) >> non_entity_object)
    if not isInsideAText(space.source) then return end -- RM(source in speech)
    task(space,function(space) -- find(entity_representative) (previous)
        space.subject = find({ h.by(std.next), h.backward },
                abstract(find({ h.by(std.repr), h.forward }, finish))
        )(space.source)
        if not space.subject then return RETRY end
    end)
    task(space,function(space) -- find(non_entity_object) (next) (language.memory.descriptor)
        space.object = find({ h.by(std.next), h.forward },
                abstract(find({ h.by(std.repr) }, finish))
        )(space.source)
        if not space.object then return RETRY end
    end)
    task(space,function(space) -- RM:SUCCESS perform clause_link
        if not space.subject or not space.object then return RETRY end
        space.link = link(space.subject,std.quality,space.object)
        link(space.source,std.repr,space.link)
    end)
end))
add(infinite_verb.acts,act(function(space)
    if not isInsideAText(space.source) then return end
    space.representative = abstract(isRepresentative(finish))(space.source)
    space.object = object("!_")
    link(space.object,std.perform,space.representative)
    link(space.source,std.repr,space.object)
end))
add(words.am.acts,act(function(space)
    if not isInsideAText(space.source) then return end
    task(space,function(space)
        space.subject_repr = find({h.by(std.next),h.forward},finish)(space.source)
        space.subject = abstract(find({ h.by(std.repr), h.forward }, finish))(space.subject_repr)
        if not space.subject then return RETRY end
    end)
    task(space,function(space)
        if not space.subject then return RETRY end
        space.object = find({h.by(std.next),h.forward},
                abstract(find({h.by(std.repr),h.forward},finish)))(space.subject_repr)
        if not space.object then return RETRY end
    end)
    task(space,function(space)
        if not space.subject or not space.object then return RETRY end
        space.info = abstract(find({h.by(std.quality),h.second(space.object)},finish))(space.subject)
        if space.info then output("yes") else output("not sure") end
    end)
end))
add(words["do"].acts,act(function(space)

end))
add(simple_verb.acts,act(function(space)
    if not isInsideAText(space.source) then return end -- RM(source in speech)
    space.representative = abstract(find({h.by(std.repr),h.forward},finish))(space.source)
    task(space,function(space) -- find(entity_representative) (previous)
        space.subject = find({ h.by(std.next), h.backward },
                abstract(find({ h.by(std.repr), h.forward }, finish))
        )(space.source)
        if not space.subject then return RETRY end
        space.link = link(space.subject,std.perform,space.representative)
    end)
    task(space,function(space) -- find(non_entity_object) (next) (language.memory.descriptor)
        space.object = find({h.by(std.next),h.forward},
                find({h.by(std.repr),h.forward},
                        where(find({h.by(std.is_a),h.second(real_object)},finish))
                )
        )(space.source)
        if not space.object then return RETRY end
    end)
    task(space,function(space) -- RM:SUCCESS perform clause_link
        if not space.link or not space.object then return RETRY end
        link(space.link,std.towards,space.object)
    end)
    task(space,function(space)
        if not space.link then return RETRY end
        link(space.source,std.repr,space.link)
    end)
end))
add(past_participle.acts,act(function(space)
    task(space,function(space)
        space.link = find({h.by(std.repr),h.forward},finish)(space.source)
        if not space.link then return RETRY end
        space.event = object("!@event"):where(std.is_a,event)
        link(time(),std.after,space.event)
        link(space.link,std.at,space.event)
    end)
end))
add(words.a.acts,act(function(space)
    if not isInsideAText(space.source) then return end
    link(space.source,std.repr,object("!a"):where(std.is_a,real_object))
end))
add(words.what.acts,act(function(space) -- RM(source -> !did -> !object_group -> !verb) e.g. what am I
    if not isInsideAText(space.source) then return end
    task(space,function(space)
        space.is = isNext(
                where(abstract(find({ h.by(std.is_a) },h.second(words.is),finish)))
        )(space.source)
        if not space.is then return RETRY end
    end)
    task(space,function(space)
        if not space.is then return RETRY end
        space.subject = find({h.by(std.next),h.forward},
                abstract(find({h.by(std.repr),h.forward},finish))
        )(space.is)
        if not space.subject then return RETRY end
    end)
    task(space,function(space)
        if not space.subject then return RETRY end
        -- auxiliary
    end)
    task(space,function(space)
        if not space.is or not space.subject then return RETRY end
        space.info = propagate({h.by(std.quality),h.forward},function(begin) print(begin) return nil end,
                find({h.by(std.repr),h.backward},
                        where(find({h.by(std.is_a),h.second(word)},finish))))(space.subject)
        space.subject:about()
        space.word = (space.info)
    end)
    task(space,function(space)
        if isTextComplete(space.source) then notSure.run(space) return FINISH end
        if not space.word then return RETRY end
        output(space.word.literal) -- non standard
    end)
end))
add(words.say.acts,act(function(space) -- RM(source -> text) (this is imperative)

end))
add(preposition.acts,act(function(space)
    --[[find({h.by(std.next),h.backward},
            find({})
    )(space.source)]]
end))
add(words.hurl.acts,act(function(space)
    for _,group in pairs(speaker0.links) do
        for _,link in pairs(group) do print(link) end
    end
    for _,link in pairs(speaker0.links[std.quality]) do
        link:about()
    end
end))
add(words.goodbye.acts,act(function(space)
    output("goodbye")
    shutdown = true
end))
add(words.sleep.acts,act(function(space)
    space.left = isPrevious(finish)(space.source)
    sleep()
end))
add(words.hello.acts,act(function(space) -- RM(hello (alone))
    output("hello")
end))

--- Unknown
--- No clue why this was lying around, just cleaning up... (seems to be related to Archive 2...)

add(words.tasty.acts,act(function(space)
    space.current_word = space.source
    function space.make_adjective_phrase()
        space.adjective_phrase = object("!AP")
        link(space.adjective_phrase,std.is_a,adjective_phrase)
    end
    space.previous_word = get_previous_word(space.source)
    if space.previous_word then
        find(space.previous_word,
                {helper.by(std.inside),helper.forward()},
                {helper.by(std.is_a),helper.forward(),helper.second(adjective_phrase)},
                function(result,link) space.adjective_phrase = link.first return true end)
    else
        space.make_adjective_phrase()
    end
    link(space.current_word,std.inside,space.adjective_phrase)
end))
