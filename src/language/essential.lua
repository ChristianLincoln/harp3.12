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

function verb_combo(representative,past,infinite,stative,concept)
    words[past] = object("~'"..past):where(std.is_a,verb):where(std.repr,representative):where(std.is_a,past_verb):where(std.is_a,acting_verb)
    words[infinite] = object("~'"..infinite):where(std.is_a,verb):where(std.repr,representative):where(std.is_a,infinite_verb)
    words[stative] = object("~'"..stative):where(std.is_a,verb):where(std.repr,representative):where(std.is_a,stative_verb):where(std.is_a,acting_verb)
    words[concept] = object("~'"..concept):where(std.is_a,proper_noun):where(std.repr,representative)
end
function noun_combo(representative,singular,plural)
    words[singular] = object("~'"..singular):where(std.is_a,class_noun):where(std.repr,representative)
    if plural then words[plural] = object("'~"..plural):where(std.is_a,class_noun):where(std.repr,representative) end
end
function adjective_combo(representative,concept,descriptor)
    words[concept] = object("~'"..concept):where(std.is_a,proper_noun):where(std.repr,representative)
    words[descriptor] = object("~'"..descriptor):where(std.is_a,adjective):where(std.repr,representative)
end
function proper_combo(representative,...)
    for _,name in pairs({...}) do
        words[name] = object("~'"..name):where(std.is_a,proper_noun):where(std.repr,representative)
    end
end
function simple_word(name)
    words[name] = object("~'"..name)
    return words[name]
end