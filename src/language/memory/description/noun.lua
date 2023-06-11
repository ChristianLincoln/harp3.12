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