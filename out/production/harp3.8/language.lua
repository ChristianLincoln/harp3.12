_G = require("cortex")

consumption = object("~consumption")
coming = object("~coming")
flavourful = object("~flavourful")

feeling = object("~feeling")
happiness = object("^happiness")
link(happiness,std.causes,std.good).pressure = 0.5
link(happiness,std.is_a,feeling)
sadness = object("^sadness")
link(sadness,std.causes,std.bad).pressure = 0.5
link(happiness,std.is_a,feeling)

hashtag = object("!self")
speaker0 = object("!speaker0")
today = object("!today@"..tostring(os.time()))
consumable = object("~food")
cookie = object("~cookie")
store = object("~store")
link(cookie,std.is_a,consumable)

letter = object("~letter")
clause = object("~clause") -- SVO structured language particle
word = object("~word")
proper_noun = object("~named_noun") -- John Doe,Schooner Way,Cardiff...happiness,sadness inferred from their adjectives/
class_noun = object("~class_noun") -- known to you as a normal noun: dog,cat,mountain...
time_word = object("~time_word")
verb = object("~verb")
simple_verb = object("~simple_verb")
adjective = object("~adjective")
adverb = object("~adverb")
pressure_adjective = object("~pressure_adjective")

entity = object("~entity")
group = object("~group") -- language group...
link_group = object("~link_group")
object_group = object("~object_group")

-- https://eslgrammar.org/verbs/ How can these verb classes affect how memory interprets each
-- Dynamic Verbs: Subject -> Performs Action -> Dynamic Verb "He ate"
--  These show the subject doing the the action of the object
-- Transitive Verbs: Resulting Link -> Applied To -> Entity "He ate the food"
--  These effectively take extra arguments (by valency) towards the link created from the verb
-- Stative Verbs: Subject -> Performs ACTION -> Stative Verb "I eat food"
--  Using an undefined time period so that the resulting link could occur at any time
-- Linking Verbs: Subject -> Has Quality -> Object "I am sad" "I feel bad" "I became angry"
--  These describe the subject of a sentence having the quality of the object
-- Different Verbs can apply different things to the resulting link from its verb class
-- Verbs can take multiple classes simultaneously and change class depending on the sentence:
-- "He turned white" (linking) "He turned" (intransitive dynamic)

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

function get_object_group(current_word)
    local previous = get_previous_word(current_word)
    local group
    find(previous,
            {helper.by(std.inside),helper.forward(),helper.first(previous)},
            {helper.by(std.is_a),helper.forward(),helper.second(object_group)},
            function(result,link) group = link.first return STOP end)
    local representative = get_representative(group)
    return group,representative
end

function get_representative(current_group)
    local representative
    find(current_group,
            {helper.by(std.is_a),helper.forward()},
            {helper.by(std.repr),helper.forward()},
    function(result,link) representative = result return STOP end)
    return representative
end

function make_object_group()
    local group = object("[]")
    local representative = object("!")
    link(group,std.is_a,object_group)
    link(group,std.repr,representative)
    return group,representative
end

words.hello = object("~'hello")
add(words.hello.acts,act(function(space)
    output("hello")
end))
words.a = object("~'a")
add(words.a.acts,act(function(space)
    space.group,space.repr = make_object_group()
    link(space.source,std.inside,space.group)
end))
words.the = object("~'the")
words.is = object("~'is")
words.am = words.is
words.are = words.is
words.you = object("~'you")
words.i = object("~'i")
add(words.i.acts,act(function(space)
    space.group,space.repr = get_object_group(space.source)
    if not space.group then space.group,space.group_repr = make_object_group() end
end))
add(class_noun.acts,act(function(space)
    space.group,space.group_repr = get_object_group(space.source)
    space.word_repr = get_representative(space.source)
    if not space.group then space.group,space.group_repr = make_object_group() end
    link(space.group_repr,std.is_a,space.word_repr,ALLOW_UNKNOWN)
    link(space.source,std.inside,space.group,ALLOW_UNKNOWN)
end))
add(adjective.acts,act(function(space)
    space.group,space.group_repr = get_object_group(space.source)
    space.word_repr = get_representative(space.source)
    if not space.group then space.group,space.group_repr = make_object_group() end
    link(space.group_repr,std.quality,space.word_repr,ALLOW_UNKNOWN)
    link(space.source,std.inside,space.group,ALLOW_UNKNOWN)
end))
add(simple_verb.acts,act(function(space)

end))
words.about = object("~'about")
--[[add(words.about.acts,act(function(space)
    space.group = get_object_group(space.source)
    space.group_repr = get_representative(space.group)
    if space.group_repr then io.write("#: ") space.group_repr:about() end
end))]]
words.happy = object("~'happy"):where(std.is_a,adjective):where(std.repr,happiness)
words.sad = object("~'sad"):where(std.is_a,adjective):where(std.repr,sadness)
words.tasty = object("~'tasty"):where(std.is_a,adjective):where(std.repr,flavourful)
words.good = object("~'good"):where(std.is_a,adjective):where(std.repr,std.good)
words.bad = object("~'bad"):where(std.is_a,adjective):where(std.repr,std.bad)
words.eating = object("~'eating")
words.ate = object("~'ate"):where(std.is_a,simple_verb):where(std.repr,consumption)
words.what = object("~'what")
words.today = object("~'today")
words.cookie = object("~'cookie"):where(std.is_a,class_noun):where(std.repr,cookie)
words.store = object("~'store"):where(std.is_a,class_noun):where(std.repr,store)
words.say = object("~'say")
words.what = object("~'what")
words.went = object("~'go"):where(std.is_a,simple_verb):where(std.repr,coming)

add(words.what.acts,act(function(space)

end))
add(words.say.acts,act(function(space)

end))

main()