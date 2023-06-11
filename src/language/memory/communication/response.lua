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

--[[ Hello Action
Simply echoes "hello"
In future this should be developed to take regard to being referred to and should wait until the speech is completely finished.
It would also be beneficial to be able to explain this word through language rather than as an action to demonstrate functionality.
]]
simple_word("hello")
add(words.hello.acts,act(function(space)
    -- should check if unqualified first
    output("hello")
end))
