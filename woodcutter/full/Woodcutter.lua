break_wood = require("BreakWood")
woodcutter = {}

COAL_SLOT = 2
woodcutter.FARM_X_SIZE = tonumber(arg[1]) or 3
woodcutter.FARM_Z_SIZE = tonumber(arg[2]) or 3
woodcutter.DEFAULT_DIR = arg[3] or COORDS.DIRECTIONS.NORTH
woodcutter.DEFAULT_SIDE = arg[4] or COORDS.DIRECTIONS.EAST
woodcutter.FARM_START_X = tonumber(arg[5]) or 0
woodcutter.FARM_START_Y = tonumber(arg[6]) or 0
woodcutter.FARM_START_Z = tonumber(arg[7]) or 0


break_wood.original_direction = 'east'
woodcutter.break_wood = break_wood

function woodcutter.init()
    print("Initializing woodcutter...")
    COORDS.LoadCoordinates()
    COORDS.MoveToCords(woodcutter.FARM_START_X, woodcutter.FARM_START_Y, woodcutter.FARM_START_Z)
    COORDS.turnToDirection(woodcutter.DEFAULT_SIDE)

    woodcutter.FARM_SIZE = woodcutter.FARM_X_SIZE * woodcutter.FARM_Z_SIZE
    woodcutter.START_X = woodcutter.FARM_START_X
    woodcutter.START_Z = woodcutter.FARM_START_z

    if woodcutter.DEFAULT_DIR == COORDS.DIRECTIONS.NORTH then
        woodcutter.END_Z = woodcutter.FARM_START_Z + -woodcutter.FARM_Z_SIZE
    elseif woodcutter.DEFAULT_DIR == COORDS.DIRECTIONS.SOUTH then
        woodcutter.END_Z = woodcutter.FARM_START_Z  + woodcutter.FARM_Z_SIZE
    end


    if woodcutter.DEFAULT_SIDE == COORDS.DIRECTIONS.EAST then
        woodcutter.END_X = woodcutter.FARM_START_X + woodcutter.FARM_X_SIZE
    elseif woodcutter.DEFAULT_SIDE == COORDS.DIRECTIONS.WEST then
        woodcutter.END_X = woodcutter.FARM_START_X -woodcutter.FARM_X_SIZE
    end


print("Starting position: X: " .. woodcutter.START_X .. " Y: " .. woodcutter.FARM_START_Y .. " Z: " .. woodcutter.FARM_START_Z)
print("Ending position: X: " .. woodcutter.END_X .. " Y: " .. woodcutter.FARM_START_Y .. " Z: " .. woodcutter.END_Z)

    woodcutter.START_POS = COORDS.getPosition()
    return true
end


function woodcutter.refuel()
    turtle.select(COAL_SLOT)
    while turtle.getFuelLevel() < 1000 do
        print("Refueling...")
        turtle.refuel(1)
    end
end

function woodcutter.breaker()

    while COORDS.Z ~= woodcutter.END_Z do
        local older_x = COORDS.X
        COORDS.SingleMoveToCords(COORDS.X, COORDS.Y, woodcutter.END_Z)
        woodcutter.break_wood.BreakAndStoreTree()
        while COORDS.X ~= woodcutter.END_X do 
            COORDS.SingleMoveToCords(woodcutter.END_X, COORDS.Y, COORDS.Z)
            woodcutter.break_wood.BreakAndStoreTree()
        end
        COORDS.MoveToCords(older_x, COORDS.Y, COORDS.Z)
    end
end


function woodcutter:StoreAndLoadItems()
    COORDS.turnToDirection(COORDS.DIRECTIONS.WEST)
    for i=1, 6 do 
    turtle.suck()
    end
    print("suckou tudo")
    for i=1, 16 do
        local slot = turtle.getItemDetail(i)
        if slot  and slot.name then
            if slot.name:find('coal') then
                turtle.select(i)
                turtle.transferTo(COAL_SLOT, 64)
                print("Transferring " .. slot.name .. " to slot " .. COAL_SLOT)
            elseif slot.name:find("sapling") then
                turtle.select(i)
                turtle.transferTo(woodcutter.break_wood.sappling_slot, 64)
                print("Transferring " .. slot.name .. " to slot " .. woodcutter.break_wood.sappling_slot)
            else
                print("Storing " .. slot.name .. " in slot " .. i)
                turtle.select(i)
                turtle.drop()
            end
        end
    end
    COORDS.turnToDirection(woodcutter.DEFAULT_DIR)
end

function woodcutter.start()
    COORDS.MoveToCords(woodcutter.FARM_START_X, woodcutter.FARM_START_Y, woodcutter.FARM_START_Z)
    woodcutter:StoreAndLoadItems()
    woodcutter.refuel()
    local sapplings = turtle.getItemDetail(woodcutter.break_wood.sappling_slot)
    if not sapplings then
        print("No sapplings found in slot " .. woodcutter.break_wood.sappling_slot)
        return false
    elseif not sapplings.name:find("sapling") then
        print("No sapplings found in slot " .. woodcutter.break_wood.sappling_slot)
        return false
    end

    if not woodcutter.init() then
        print("Failed to initialize woodcutter.")
        return false
    end
    COORDS.init()
    print("Starting woodcutter...")
    woodcutter.breaker()
    COORDS.MoveToCords(woodcutter.START_POS.X, woodcutter.START_POS.Y, woodcutter.START_POS.Z)
    print("Finished woodcutting.")
    COORDS.turnToDirection(woodcutter.START_POS.DIRECTION)
end


while true do
    woodcutter.start()
    --sleep 50
    os.sleep(50)
end