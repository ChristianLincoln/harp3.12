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
