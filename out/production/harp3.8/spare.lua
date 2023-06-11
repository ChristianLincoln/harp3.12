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