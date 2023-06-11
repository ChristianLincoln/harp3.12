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
