turtle = turtle
-- BreakWood Algorithm
moves = {}
function GoToGroundLevel()
    local found = false
    print("Going to ground level")
    while not found do
        local success, data = turtle.inspectDown()
        if success then
            print("Found block below, block is " .. data.name)
            if data.name == "minecraft:grass_block" or data.name == "minecraft:dirt" then
                print("Found ground level")
                found = true
                return true
            end
        end
        turtle.down()
    end
end

function LookAroundForTree(moves)
    print("Looking around for tree")
    local found = false

    movements = {
        first_right='right',
        second_right='backward',
        third_right='left',
        fourth_right='forward'
    }

    for i = 1, 4 do
        move = movements[i]
        local success, data = turtle.inspect()
        if success then
            if data.name == "minecraft:oak_log" or data.name == "minecraft:birch_log" or data.name == "minecraft:spruce_log" then
                print("Found tree on i=" .. i)
                if moves == nil then
                    return true
                else
                    print("Found tree on i=" .. i .. " and moves is not nil")
                    moves[#moves + 1] = {
                        move=move,
                        status='todo',
                        id=#moves+1
                    }
                end
            end
        end
        turtle.turnRight()
    end
end


function FindTree()
    GoToGroundLevel()
    print("Finding tree")
    local found = false
    while not found do
        LookAroundForTree()
        local success, data = turtle.inspect()
        if success then
            if data.name == "minecraft:oak_log" or data.name == "minecraft:birch_log" or data.name =="minecraft:spruce_log" then
                print("Found tree")
                found = true
                return true
            end
        end
        turtle.forward()
        GoToGroundLevel()
    end
end

function GoDownTree()
    FindTree()
    GoToGroundLevel()
    turtle.dig()
    turtle.forward()
end

function BreakUpTree()
    while true do
        local sucess,upper_block = turtle.inspectUp()
        if sucess then
            if upper_block.name == "minecraft:oak_log" or upper_block.name == "minecraft:birch_log" or upper_block.name == 'minecraft:spruce_log' then
                turtle.digUp()
                turtle.up()
                moves[#moves + 1] = {
                    move='up',
                    status='finished',
                    id=#moves+1
                }
            else
                break
            end
        else
            break
        end
    end
end

function ReturnToStart()
    for i = #moves, 1, -1 do
        local move = moves[i]
        if move.status == 'todo' then
            if move.move == 'up' then
                turtle.down()
            elseif move.move == 'forward' then
                turtle.back()
            elseif move.move == 'backward' then
                turtle.forward()
            elseif move.move == 'left' then
                turtle.turnLeft()
            elseif move.move == 'right' then
                turtle.turnRight()
            end
        end
    end
end


function BreakAndStoreTree()
    GoDownTree()
    local moves = {}
    BreakUpTree()
    GoToGroundLevel()
end

BreakAndStoreTree()