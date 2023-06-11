_G = require("system")
require.tree('language')
-- _ blank
-- ~ class
-- ^ standard
-- ! instance
-- [] manifest
-- > relational

-- a little note on what std. actually is right now:
-- std.inside
-- std.repr ( What does this mean? Literally: LNK(!,std.repr,?) )
-- std.quality ( What is this? What is this a? )
-- std.perf ( When something does something... )
-- std.cause ( When something leads to something else (this standard is backwards) )
-- std.owns?

text = object("~text")
word = object("~word")
complete = object("~complete")
link(complete,std.causes,std.good).pressure=0.15

performance = object("~performance")
consumption = object("~consumption"):where(std.is_a,performance)
coming = object("~coming")
flavourful = object("~flavourful")
perform = object("~perform") -- std?...
towards = object("~towards")
valency = object("~valent")
alongside = object("~with")
speaking = object("~speaking")
sleeping = object("~sleeping")

real_quality = object("~quality")
real_object = object("~entity")

feeling = object("~feeling")
happiness = object("^happiness"):where(std.is_a,real_quality)
link(happiness,std.causes,std.good).pressure = 0.5
link(happiness,std.is_a,feeling)
sadness = object("^sadness"):where(std.is_a,real_quality)
link(sadness,std.causes,std.bad).pressure = 0.5
link(happiness,std.is_a,feeling)
expect = object("~habitual")

human = object("~human")
hashtag = object("!self"):where(std.is_a,real_object)

today = object("!today@"..tostring(os.time()))
consumable = object("~food")
store = object("~store")

letter = object("~letter")
clause = object("~clause") -- SVO structured language particle

time_word = object("~time_word")

adverb = object("~adverb")
time_phrase = object("~time_phrase")
pressure_adjective = object("~pressure_adjective")
preposition = object("~preposition")
stative_verb = object("~stative_verb")
interrogatory = object("~interrogatory")
present_verb = object("~present_verb")

group = object("~group") -- language group...
link_group = object("~link_group")
object_group = object("~object_group")

subject = object("~subject")
target = object("~object")

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

words = {} -- supplementary for recognition

verb = object("~verb")
acting_verb = object("~acting_verb"):where(std.is_a,verb)
past_verb = object("~past_verb"):where(std.is_a,verb)
infinite_verb = object("~infinite_verb"):where(std.is_a,verb)
stative_verb = object("~stative_verb"):where(std.is_a,verb)

adjective = object("~adjective")

noun = object("~noun")
proper_noun = object("~named_noun")   -- John Doe,Schooner Way,Cardiff...happiness,sadness inferred from their adjectives/
class_noun = object("~class_noun") -- known to you as a normal noun: dog,cat,mountain...

local function verb_combo(representative,past,infinite,stative,concept)
    words[past] = object("~'"..past):where(std.is_a,verb):where(std.repr,representative):where(std.is_a,past_verb):where(std.is_a,acting_verb)
    words[infinite] = object("~'"..infinite):where(std.is_a,verb):where(std.repr,representative):where(std.is_a,infinite_verb)
    words[stative] = object("~'"..stative):where(std.is_a,verb):where(std.repr,representative):where(std.is_a,stative_verb):where(std.is_a,acting_verb)
    words[concept] = object("~'"..concept):where(std.is_a,proper_noun):where(std.repr,representative)
end
local function noun_combo(representative,singular,plural)
    words[singular] = object("~'"..singular):where(std.is_a,class_noun):where(std.repr,representative)
    if plural then words[plural] = object("'~"..plural):where(std.is_a,class_noun):where(std.repr,representative) end
end
local function adjective_combo(representative,concept,descriptor)
    words[concept] = object("~'"..concept):where(std.is_a,proper_noun):where(std.repr,representative)
    words[descriptor] = object("~'"..descriptor):where(std.is_a,adjective):where(std.repr,representative)
end
local function proper_combo(representative,...)
    for _,name in pairs({...}) do
        words[name] = object("~'"..name):where(std.is_a,proper_noun):where(std.repr,representative)
    end
end
local function simple_word(name)
    words[name] = object("~'"..name)
    return words[name]
end

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
simple_word("hello")

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

-- note, in this line, a find manifest has been created and can be used anywhere as though a function
isInsideAText=find({h.by(std.inside),h.forward},where(find({h.by(std.is_a),h.forward,h.second(text)},finish)))
isTextComplete=find({h.by(std.inside),h.forward},where(find({h.by(std.is_a),h.forward,h.second(text)},finish),find({h.by(std.quality),h.second(complete)},finish)))
abstract=function(...)
    return propagate(2,{h.by(std.is_a)},...)
end -- AMEND: deduced links helps with optimisation; if an object
isRepresentative=function(...)
    return find({h.by(std.repr),h.forward},...)
end
isRelevant=function(...)
    return find({h.by(std.next)},...)
end
isNext=function(...)
    return find({h.by(std.next),h.forward},...) -- abstract(find({h.by(std.is_a),h.second(word)},...))
end
isPrevious=function(...)
    return find({h.by(std.next),h.backward},...) -- abstract(find({h.by(std.is_a),h.second(word)},...))
end
isA=function(class)
    return function(...)
        return propagate(2,{h.by(std.is_a),h.second(class)},...)
    end
end
isUnqualified=function(...) -- meaning the word isn't already in a SVO structure of some sort
    return function(...)
        return ... -- doing this here because I haven't solved the find manifest for this yet
    end
end
isComplete=find({h.by(std.quality),h.second(std.complete)},finish)
nearWord=function(limit,direction,...)
    return propagate(limit,{h.by(std.next),direction},...)
end
isARealObject=isA(real_object)
isARealQuality=isA(real_quality)
isAWord=isA(word)
isNounWord=where(isRepresentative(isARealObject(finish)))
isVerbWord=where(abstract(isA(verb)(finish)))

--[[ Actions in language will not follow standard english grammatical rules as with previous archives.
 Abstraction is important to facilitate truly effective communication, for example, what if I missed out a word or didn't understand english well?
 Therefore, all actions in my third language model will operate under the premise that this system is communicating with a developing child

-- Subject: find({h.by(s.inside),h.forward),find({h.by(s.inside),h.backward},find({h.by(s.repr),h.forward},finish)))(space.source)

--[[ Adjective Action:
An adjective is a describing word, it has been observed in natural language that adjectives simply represent a quality and make an attempt
to assign that quality to any related objects in short memory. Thus, 'dog good' would operate so that the adjective action assumes relation.
Furthermore, in natural language a human could simply reply 'good!' to an event and the recipient would infer that the situation was the subject.
In true grammar, the adjective comes before the noun. Here, the action would rely on a preceding 'a' or create a blank object in preparation of
assignment.
]]
add(adjective.acts,act(function(space)
    if not isInsideAText(space.source) then return FINISH end
    space.repr = abstract(isRepresentative(finish))(space.source) -- isARealQuality
    task(space,function(space)
        space.object = isRelevant(abstract(isRepresentative(where(isARealObject(finish)))))(space.source)
                or object("!"):where(std.is_a,real_object) -- find the first related object and attach to it
        space.object.name = space.object.name..space.repr.name
        space.result = link(space.object,std.quality,space.repr)
        link(space.result,std.because,space.source)
        link(space.source,std.repr,space.object)
    end)
end))
--[[ Proper Noun Action:
Proper nouns in english are highly simplistic in their functionality. Most of them operate as a representative.
In this project, proper nouns have been assumed to be equal to abstract nouns because they are both named,
this simply means there is no regard given to the type of object a proper noun refers to.
]]
add(proper_noun.acts,act(function(space)
    space.repr = abstract(isRepresentative(finish))(space.source)
    link(link(space.source,std.repr,space.repr),std.because,space.source) -- an inferred link optimises
end))
--[[ Class Noun Action:
Class nouns are more complex in english, proper nouns can also be treated as class nouns to some extent, 'another Windows PC'
A class noun fulfils a similar purpose to an adjective but more relevant to the object's inherited qualities rather than direct qualities.
e.g. you are a dog: LNK(you->quality->!OBJ) LNK(!OBJ->quality->dog) ...LNK(you->quality->dog) (because of abstraction/propagation)
]]
add(class_noun.acts,act(function(space)
    if not isInsideAText(space.source) then return FINISH end
    space.repr = abstract(isRepresentative(finish))(space.source)
    task(space,function(space)
        space.object = isRelevant(abstract(isRepresentative(where(isARealObject(finish)))))(space.source)
                or object("!"):where(std.is_a,real_object) -- find the first related object and attach to it
        space.object.name = space.object.name..space.repr.name
        space.result = link(space.object,std.quality,space.repr)
        link(space.result,std.because,space.source)
        link(space.source,std.repr,space.object)
    end)
end))
-- Note: saying 'good dog' and 'dog good' are equal in meaning, but one of the words founds the object before another, the other simply hitches a ride.
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

quality_act = act(function(space)
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
end)
simple_word("am"):where(std.is_a,verb):where(std.is_a,present_verb)
add(words.am.acts,quality_act)
simple_word("was"):where(std.is_a,verb):where(std.is_a,past_verb)
add(words.was.acts,quality_act)
simple_word("were"):where(std.is_a,verb):where(std.is_a,past_verb)
add(words.were.acts,quality_act)
-- Past Tense, states that the resultant link occurred at a previous event

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
A preposition simply sets the by term of a linked link (an adverb type construct). They make a verb structure polyvalent
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
add(words.hello.acts,act(function(space)
    -- should check if unqualified first
    output("hello")
end))

--[[
v: verb
n: next
r: representative
]]
simple_word("nhurl")
add(words.nhurl.acts,act(function(space)
    space.link = nearWord(1,h.backward,isNounWord)(space.source)
    if space.link then space.link:about() else output("hurl: fail") end
end))
simple_word("nrhurl")
add(words.nrhurl.acts,act(function(space)
    space.link = nearWord(1,h.backward,isNounWord)(space.source)
    space.link = isRepresentative(finish)(space.link)
    if space.link then space.link:about() else output("hurl: fail") end
end))
simple_word("vrhurl")
add(words.vrhurl.acts,act(function(space)
    space.text = isInsideAText(space.source)
    task(space,function(space)
        space.link = nearWord(10,h.backward,isVerbWord)(space.source)
        space.link = isRepresentative(finish)(space.link)
        if not space.link then return RETRY end
        space.link:about()
    end)
end))

task({},function(space)
    -- ok so loopback through recent time... has anything happened? no, so ask how am i... init...
end)

test="fourth"
tests = {}
tests.first = {"hello","i am","i am happy","i am a human","i ate","i ate a cookie","what am i","sleep","am i"} -- Archive 4
tests.second = {"i am revising","what am i"} -- Archive 4
tests.third = {"i good","i went home","home i went","i ate cookie","i ate a cookie","i ate a cookie vrhurl","i am going home","i am good vrhurl"}
tests.fourth = {"i am revising vrhurl"}
test = tests[test]
main(test)

-- i am going to the boarding house
-- i was going to the boarding house

-- what are you doing?
-- how are you?