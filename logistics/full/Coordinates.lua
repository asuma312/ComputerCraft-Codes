Typing = require("Typing")
json = require("json")

turtle = turtle

COORDS = {
    X = 0,
    Y = 0,
    Z = 0,
    DIRECTION = "north",
}

COORDS.DIRECTIONS = {
    NORTH = "north",
    SOUTH = "south",
    EAST = "east",
    WEST = "west"
}

COORDS.DIRECTION = COORDS.DIRECTIONS.NORTH

COORDS.MOVEMENTS = {
    FORWARD = "forward",
    BACKWARD = "backward",
    UP = "up",
    DOWN = "down",
    LEFT = "left",
    RIGHT = "right"
}

function COORDS.init()
    print("starting init")
    COORDS.LoadCoordinates()
end

function COORDS.SaveCoordinates(X,Y,Z,DIRECTION)
    if X ~= nil then COORDS.X = X end
    if Y ~= nil then COORDS.Y = Y end
    if Z ~= nil then COORDS.Z = Z end
    if DIRECTION ~= nil then COORDS.DIRECTION = DIRECTION end
    local coordinates = {
        X = COORDS.X,
        Y = COORDS.Y,
        Z = COORDS.Z,
        DIRECTION = COORDS.DIRECTION
    }
    local json_data = json.encode(coordinates)
    local file = fs.open("coordinates.json", "w")
    file.write(json_data)
    file.close()
end

function COORDS.LoadCoordinates()
    if fs.exists("coordinates.json") then
        local file = fs.open("coordinates.json", "r")
        local json_data = file.readAll()
        file.close()
        local coordinates = json.decode(json_data)
        COORDS.X = coordinates.X
        COORDS.Y = coordinates.Y
        COORDS.Z = coordinates.Z
        COORDS.DIRECTION = coordinates.DIRECTION
        print("Coordinates loaded from coordinates.json")
    else
        COORDS.X = 0
        COORDS.Y = 0
        COORDS.Z = 0
        COORDS.DIRECTION = COORDS.DIRECTIONS.NORTH
        print("No saved coordinates found.")
    end
end


function COORDS.move(MOVEMENT)
    local success = false
    local direction = Typing.VerifyEnum(COORDS.MOVEMENTS, MOVEMENT)
    if direction == nil then
        print("Movimento inválido: " .. MOVEMENT)
        return
    end
    
    if direction == "forward" then
        turtle.dig()
        success = turtle.forward()
        if success then
            if COORDS.DIRECTION == COORDS.DIRECTIONS.NORTH then 
                COORDS.Z = COORDS.Z - 1
            elseif COORDS.DIRECTION == COORDS.DIRECTIONS.SOUTH then 
                COORDS.Z = COORDS.Z + 1
            elseif COORDS.DIRECTION == COORDS.DIRECTIONS.EAST then 
                COORDS.X = COORDS.X + 1
            elseif COORDS.DIRECTION == COORDS.DIRECTIONS.WEST then 
                COORDS.X = COORDS.X - 1
            end
        end
    elseif direction == "up" then
        turtle.digUp()
        success = turtle.up()
        if success then 
            COORDS.Y = COORDS.Y + 1 
        end
    elseif direction == "down" then
        turtle.digDown()
        success = turtle.down()
        if success then 
            COORDS.Y = COORDS.Y - 1 
        end
    end

    COORDS.SaveCoordinates()
    
    return success
end

function COORDS.turnLeft()
    turtle.turnLeft()
    if COORDS.DIRECTION == COORDS.DIRECTIONS.NORTH then 
        COORDS.DIRECTION = COORDS.DIRECTIONS.WEST
    elseif COORDS.DIRECTION == COORDS.DIRECTIONS.WEST then 
        COORDS.DIRECTION = COORDS.DIRECTIONS.SOUTH
    elseif COORDS.DIRECTION == COORDS.DIRECTIONS.SOUTH then 
        COORDS.DIRECTION = COORDS.DIRECTIONS.EAST
    elseif COORDS.DIRECTION == COORDS.DIRECTIONS.EAST then 
        COORDS.DIRECTION = COORDS.DIRECTIONS.NORTH
    end
end

function COORDS.turnRight()
    turtle.turnRight()
    if COORDS.DIRECTION == COORDS.DIRECTIONS.NORTH then 
        COORDS.DIRECTION = COORDS.DIRECTIONS.EAST
    elseif COORDS.DIRECTION == COORDS.DIRECTIONS.EAST then 
        COORDS.DIRECTION = COORDS.DIRECTIONS.SOUTH
    elseif COORDS.DIRECTION == COORDS.DIRECTIONS.SOUTH then 
        COORDS.DIRECTION = COORDS.DIRECTIONS.WEST
    elseif COORDS.DIRECTION == COORDS.DIRECTIONS.WEST then 
        COORDS.DIRECTION = COORDS.DIRECTIONS.NORTH
    end
end

function COORDS.turnToDirection(direction)

    local targetDirection = Typing.VerifyEnum(COORDS.DIRECTIONS, direction)
    if targetDirection == nil then
        print("Direção inválida: " .. direction)
        return
    end
    if COORDS.DIRECTION == targetDirection then return end
    
    if (COORDS.DIRECTION == COORDS.DIRECTIONS.NORTH and targetDirection == COORDS.DIRECTIONS.EAST) or
       (COORDS.DIRECTION == COORDS.DIRECTIONS.EAST and targetDirection == COORDS.DIRECTIONS.SOUTH) or
       (COORDS.DIRECTION == COORDS.DIRECTIONS.SOUTH and targetDirection == COORDS.DIRECTIONS.WEST) or
       (COORDS.DIRECTION == COORDS.DIRECTIONS.WEST and targetDirection == COORDS.DIRECTIONS.NORTH) then
        COORDS.turnRight()
        COORDS.SaveCoordinates()
    else
        COORDS.turnLeft()
        COORDS.SaveCoordinates()
    end
    
    if COORDS.DIRECTION ~= targetDirection then
        COORDS.turnToDirection(targetDirection)
        
    end
end


function COORDS.SingleMoveToCords(local_X, local_Y, local_Z)


    local attempts = {}

    if COORDS.Y < local_Y then
        table.insert(attempts, {move=COORDS.MOVEMENTS.UP})
    elseif COORDS.Y > local_Y then
        table.insert(attempts, {move=COORDS.MOVEMENTS.DOWN})
    end

    if COORDS.X < local_X then
        table.insert(attempts, {turn=COORDS.DIRECTIONS.EAST, move=COORDS.MOVEMENTS.FORWARD})
    elseif COORDS.X > local_X then
        table.insert(attempts, {turn=COORDS.DIRECTIONS.WEST, move=COORDS.MOVEMENTS.FORWARD})
    end

    if COORDS.Z < local_Z then
        table.insert(attempts, {turn=COORDS.DIRECTIONS.SOUTH, move=COORDS.MOVEMENTS.FORWARD})
    elseif COORDS.Z > local_Z then
        table.insert(attempts, {turn=COORDS.DIRECTIONS.NORTH, move=COORDS.MOVEMENTS.FORWARD})
    end

    for _, attempt in ipairs(attempts) do
        if attempt.turn then
            COORDS.turnToDirection(attempt.turn)
        end
        local success = COORDS.move(attempt.move)
        if success then
            return false
        end
    end

    if COORDS.X == local_X and COORDS.Y == local_Y and COORDS.Z == local_Z then
        return true
    end

    print("Nenhum movimento possível para o destino desejado.")
    return false
end

function COORDS.MoveToCords(local_X,local_Y,local_Z)
    while not COORDS.SingleMoveToCords(local_X,local_Y,local_Z) do
    end
    COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
end

function COORDS.getPosition()
    return {
        X = COORDS.X,
        Y = COORDS.Y,
        Z = COORDS.Z,
        DIRECTION = COORDS.DIRECTION
    }
end
COORDS.init()
return COORDS