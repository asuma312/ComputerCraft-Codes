local COORDS = require("Coordinates")
turtle = turtle


-- BreakWood Algorithm
break_wood = {}
break_wood.starting_position = nil
break_wood.tree_direction = nil
break_wood.sappling_slot = 1
function break_wood.initialize()
    -- Salva a posição inicial
    break_wood.starting_position = COORDS.getPosition()
    print("Posição inicial salva: ", 
          "X="..break_wood.starting_position.X, 
          "Y="..break_wood.starting_position.Y, 
          "Z="..break_wood.starting_position.Z, 
          "DIR="..break_wood.starting_position.DIRECTION)

    
end

function break_wood.GoToGroundLevel()
    print("Going to ground level")
    while COORDS.Y < break_wood.starting_position.Y do
        COORDS.move(COORDS.MOVEMENTS.DOWN)
    end
end

function break_wood.LookAroundForTree()
    print("Looking around for tree")
    
    
    for i = 1, 4 do
        local success, data = turtle.inspect()
        if success then
            if data.name == "minecraft:oak_log" or data.name == "minecraft:birch_log" or data.name == "minecraft:spruce_log" then
                print("Found tree on i=" .. i)
                break_wood.tree_direction = COORDS.DIRECTION
                return true
            end
        end
        COORDS.turnRight()
    end
    
    -- Retorna à direção original
    COORDS.turnToDirection(break_wood.original_direction)
    return false
end

function break_wood.FindTree()
    break_wood.GoToGroundLevel()
    print("Finding tree")
    if break_wood.LookAroundForTree() then
        local success, data = turtle.inspect()
        if success and (data.name == "minecraft:oak_log" or 
                        data.name == "minecraft:birch_log" or 
                        data.name == "minecraft:spruce_log") then
            print("Found tree")
            return true
        end
    end
    return false
end

function break_wood.GoDownTree()
    if break_wood.FindTree() then
        break_wood.GoToGroundLevel()
        COORDS.move(COORDS.MOVEMENTS.FORWARD)
    end
end

function break_wood.BreakUpTree()
    while true do
        local success, upper_block = turtle.inspectUp()
        if success then
            if upper_block.name == "minecraft:oak_log" or 
               upper_block.name == "minecraft:birch_log" or 
               upper_block.name == 'minecraft:spruce_log' then
                turtle.digUp()
                COORDS.move(COORDS.MOVEMENTS.UP)
            else
                break_wood.GoToGroundLevel()
                break_wood.ReturnToStart()
                if break_wood.tree_direction ~= nil then
                    COORDS.turnToDirection(break_wood.tree_direction)
                    turtle.select(break_wood.sappling_slot)
                    turtle.place()
                    print("Planted sapling")
                end
                
                break
            end
        else
            break_wood.GoToGroundLevel()
            break_wood.ReturnToStart()
            if break_wood.tree_direction ~= nil then
                COORDS.turnToDirection(break_wood.tree_direction)
                turtle.select(break_wood.sappling_slot)
                turtle.place()
                print("Planted sapling")
            end

            break
        end
    end
end

function break_wood.ReturnToStart()
    if break_wood.starting_position then
        print("Retornando para posição inicial: ", 
              "X="..break_wood.starting_position.X, 
              "Y="..break_wood.starting_position.Y, 
              "Z="..break_wood.starting_position.Z, 
              "DIR="..break_wood.starting_position.DIRECTION)
              
        -- Move para as coordenadas iniciais        
        -- Retorna para a direção inicial

        COORDS.MoveToCords(break_wood.starting_position.X, 
                        break_wood.starting_position.Y, 
                        break_wood.starting_position.Z)
        COORDS.turnToDirection(break_wood.starting_position.DIRECTION)
    else
        print("Posição inicial não foi salva")
    end
end

function break_wood.BreakAndStoreTree()
    break_wood.initialize()
    break_wood.GoDownTree()
    break_wood.BreakUpTree()
    print("Quebra de árvore concluída")
end

-- Retornar o objeto break_wood para uso
return break_wood