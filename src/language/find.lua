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