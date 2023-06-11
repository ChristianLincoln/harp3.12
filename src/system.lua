_G = require("standard")

--[[ a typical layered Find Manifest
local source = object("ate") -- I ate
local previous = object("i")
local me = object("me")
entity = object("~entity")
human = object("~human")
link(previous,std.next,source)
link(previous,std.repr,me)
link(me,std.is_a,human)
link(me,std.is_a,entity)
local found_me =
find({ h.by(std.next), h.backward },
        find({ h.by(std.repr), h.forward },
                where(
                        find({ h.by(std.is_a), h.second(entity) }, finish),
                        find({ h.by(std.is_a), h.second(human) }, finish)
                )
        )
)(source)
if found_me == me then output("1") end
--[[]]


--[[ conceptualisation of propagation in Find Manifests
local sentence = object("text")
local clause = object("clause")
local word = object("word")
speech = object("~text")
link(word,std.inside,clause)
link(clause,std.inside,sentence)
link(sentence,std.is_a,speech)
local found_text = propagate({h.by(std.inside),h.forward},find({h.by(std.is_a),h.second(speech)},finish))(word)
if found_text == speech then output("2") end
--[[]]

function std.think()
    newTasks = {}
    for _,task in pairs(tasks) do
        if task.callback(task.space) == RETRY then
            add(newTasks,task)
        end
    end
    tasks = newTasks
end

function parse(statement)
    local input = statement.." "
    local word = ""
    local previous
    local speech = object("!speech")
    link(speech,std.is_a,text)
    link(speech,std.because,speaker0) -- speaker0 always makes speech
    for index=1,#input,1 do
        local char = string.sub(input,index,index)
        if char == " " then
            local class = words[word]
            if not class then
                words[word] = object()
                class = words[word]
            end
            word = object("!'"..word)
            if previous then link(previous,std.next,word) end
            link(word,std.inside,speech)
            link(word,std.is_a,class)
            link(word,std.inside,speech)
            --add(word.acts,aware)
            table.insert(short,1,word)
            std.think()
            previous = word
            word = ""
        else
            word = word .. char
        end
    end
    link(speech,std.quality,complete)
    std.think()
    std.sleep()
end

shutdown = false
function main(tests)
    local word_class = word
    for literal,word in pairs(words) do
        if not word.acts.aware then word.acts["aware"] = std.aware end
        word.literal = literal
        word:where(std.is_a,word_class)
    end -- make system aware of how it should respond to each word because of what it is
    if tests and not stop_tests then for _,test in pairs(tests) do print("P:",test) parse(test) end end
    while not shutdown do io.write("P:  ") io.flush() parse(io.read()) end
    print("Unhandled Tasks: "..#tasks)
    print("Finished: "..tostring(time()))
end

return _G