--[[ Proper Noun Action:
Proper nouns in english are highly simplistic in their functionality. Most of them operate as a representative.
In this project, proper nouns have been assumed to be equal to abstract nouns because they are both named,
this simply means there is no regard given to the type of object a proper noun refers to.
]]
add(proper_noun.acts,act(function(space)
    space.text = isInsideAText(space.source)
    if not space.text then return FINISH end
    space.repr = abstract(isRepresentative(finish))(space.source)
    link(link(space.source,std.repr,space.repr),std.because,space.source) -- an inferred link optimises
end))
