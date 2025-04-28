require("Typing")
print(Typing.VerifyEnum)
turtle = turtle

COORDS = {
    X=0,
    Y=0,
    Z=0
}

COORDS.DIRECTIONS = {
    NORTH = "north",
    SOUTH = "south",
    EAST = "east",
    WEST = "west"
}

COORDS.DIRECTION = COORDS.DIRECTIONS.NORTH -- Direção padrão

COORDS.MOVEMENTS = {
    FORWARD = "forward",
    BACKWARD = "backward",
    UP = "up",
    DOWN = "down",
    LEFT = "left",
    RIGHT = "right"
}

function COORDS.init()
    COORDS.X = 0
    COORDS.Y = 0
    COORDS.Z = 0
    COORDS.DIRECTION = COORDS.DIRECTIONS.NORTH
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
    else
        COORDS.turnLeft()
    end
    
    if COORDS.DIRECTION ~= targetDirection then
        COORDS.turnToDirection(targetDirection)
    end
end


function COORDS.SingleMoveToCords(local_X,local_Y,local_Z)
    print("Local atual - X=" .. COORDS.X .. ", Y=" .. COORDS.Y .. ", Z=" .. COORDS.Z)
    print("Local alvo - X=" .. local_X .. ", Y=" .. local_Y .. ", Z=" .. local_Z)
    if COORDS.X < local_X then
        COORDS.turnToDirection(COORDS.DIRECTIONS.EAST)
        COORDS.move(COORDS.MOVEMENTS.FORWARD)
    elseif COORDS.X > local_X then
        COORDS.turnToDirection(COORDS.DIRECTIONS.WEST)
        COORDS.move(COORDS.MOVEMENTS.FORWARD)
    elseif COORDS.Z < local_Z then
        COORDS.turnToDirection(COORDS.DIRECTIONS.SOUTH)
        COORDS.move(COORDS.MOVEMENTS.FORWARD)
    elseif COORDS.Z > local_Z then
        COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
        COORDS.move(COORDS.MOVEMENTS.FORWARD)
    elseif COORDS.Y < local_Y then
        COORDS.move(COORDS.MOVEMENTS.UP)
    elseif COORDS.Y > local_Y then
        COORDS.move(COORDS.MOVEMENTS.DOWN)
    else
        return true
    end    
end

function COORDS.MoveToCords(local_X,local_Y,local_Z)
    print("Local atual - X=" .. COORDS.X .. ", Y=" .. COORDS.Y .. ", Z=" .. COORDS.Z)
    print("Local alvo - X=" .. local_X .. ", Y=" .. local_Y .. ", Z=" .. local_Z)
    while not COORDS.SingleMoveToCords(local_X,local_Y,local_Z) do
    end
    COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
    print("Finished moving to target coordinates.")
end

function COORDS.getPosition()
    return {
        X = COORDS.X,
        Y = COORDS.Y,
        Z = COORDS.Z,
        DIRECTION = COORDS.DIRECTION
    }
end

return COORDS