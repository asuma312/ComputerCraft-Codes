require("Coordinates")
require("Typing")
turtle = turtle

SEEDS = {
"minecraft:carrot",
"minecraft:potato",
"minecraft:wheat_seeds",
"minecraft:beetroots",
"minecraft:melon_seeds",
"minecraft:pumpkin_seeds",
"minecraft:nether_wart",
}

SEEDS_TO_PLANT = {}
-- Farmer module
local Farmer = {}
Farmer.FARM_X_SIZE = tonumber(arg[1]) or 3
Farmer.FARM_Z_SIZE = tonumber(arg[2]) or 3


Farmer.DEFAULT_DIR = arg[3] or COORDS.DIRECTIONS.NORTH
Farmer.DEFAULT_SIDE = arg[4] or COORDS.DIRECTIONS.EAST
Farmer.FARMS = {}

FARMER_START_X = tonumber(arg[5]) or 0
FARMER_START_Y = tonumber(arg[6]) or 0
FARMER_START_Z = tonumber(arg[7]) or 0

function Farmer.init()
    -- Initialize the farmer
    print("Initializing Farmer...")
    print(#SEEDS .. " seeds found.")
    for i = 1, #SEEDS do
        local seed = SEEDS[i]
        local turtle_slot = turtle.getItemDetail(i)
        if turtle_slot == nil then
            print("Slot " .. i .. " is empty, wont be planting")
        elseif not Typing.VerifyEnum(SEEDS,turtle_slot.name) then
            print("Slot " .. i .. " is not a plant, wont be planting")
        else
            print("Slot " .. i .. " is a seed. will be planting " .. seed)
            SEEDS_TO_PLANT[#SEEDS_TO_PLANT+1] = turtle_slot.name
        end
    end
    if #SEEDS_TO_PLANT == 0 then
        print("No seeds found, exiting...")
        return false
    end
    print("loading")
    COORDS.LoadCoordinates()
    COORDS.MoveToCords(FARMER_START_X, FARMER_START_Y, FARMER_START_Z)
    COORDS.turnToDirection(Farmer.DEFAULT_DIR)

    Farmer.FARM_SIZE = Farmer.FARM_X_SIZE * Farmer.FARM_Z_SIZE
    Farmer.START_X = FARMER_START_X
    Farmer.START_Z = FARMER_START_Z

    if Farmer.DEFAULT_DIR == COORDS.DIRECTIONS.NORTH then
        Farmer.END_Z = FARMER_START_Z + -Farmer.FARM_Z_SIZE
    elseif Farmer.DEFAULT_DIR == COORDS.DIRECTIONS.SOUTH then
        Farmer.END_Z = FARMER_START_Z + Farmer.FARM_Z_SIZE
    end

    if Farmer.DEFAULT_SIDE == COORDS.DIRECTIONS.EAST then
        Farmer.END_X = FARMER_START_X + Farmer.FARM_X_SIZE
    elseif Farmer.DEFAULT_SIDE == COORDS.DIRECTIONS.WEST then
        Farmer.END_X = FARMER_START_X + -Farmer.FARM_X_SIZE
    end
    print("Farmer start x " .. Farmer.START_X .. " end x " .. Farmer.END_X)
    print("Farmer start z " .. COORDS.Z .. " end z " .. Farmer.END_Z)
--    if 1==1 then return end
    Farmer.SEEDS_PER_PLANT = Farmer.FARM_SIZE / #SEEDS
    Farmer.START_POS = COORDS.getPosition()
    return true
end

function Farmer.plant()
    local selected_seed = nil
    turtle.digDown()
    local index = 1
    while true do
        selected_seed = SEEDS_TO_PLANT[index]
        if Farmer.FARMS[selected_seed] and Farmer.FARMS[selected_seed] >= Farmer.SEEDS_PER_PLANT then
            index = index + 1
            if index > #SEEDS_TO_PLANT then
                print("All seeds have been planted.")
                Farmer.FARMS = {}
                index = 1
                break
            end
        else
            print("Planting " .. selected_seed .. " in slot " .. index)
            turtle.select(index)
            turtle.placeDown()
            Farmer.FARMS[selected_seed] = (Farmer.FARMS[selected_seed] or 0) + 1
            break
        end
    end
end

function Farmer.Harvest(block)
    local item = block.name
    local index = 1
    turtle.digDown()
    for i=1, 16 do
        local turtle_slot = turtle.getItemDetail(i)
        if turtle_slot and turtle_slot.name == item then
            turtle.select(i)
            break
        end
    end
    turtle.placeDown()
    print("Harvested " .. item)
end

function Farmer.planter()
    print("Changing direction to " .. Farmer.DEFAULT_SIDE)
    COORDS.turnToDirection(Farmer.DEFAULT_SIDE)
    COORDS.move(COORDS.MOVEMENTS.UP)
    while COORDS.X ~= Farmer.END_X do
        COORDS.SingleMoveToCords(Farmer.END_X, COORDS.Y, COORDS.Z)
        local older_z = COORDS.Z
        
        sucess, block = turtle.inspectDown()
        if not sucess then
            print("No block found, planting")
            Farmer.plant()
        else
            if block.state.age == 7 then
                print("Block is ready to harvest")
                Farmer.Harvest(block)
            else
                print("Block is not ready to harvest, age is " .. block.state.age)
            end
        end
        while COORDS.Z ~= Farmer.END_Z do 
            COORDS.SingleMoveToCords(COORDS.X, COORDS.Y, Farmer.END_Z)
            sucess, block = turtle.inspectDown()
            if not sucess then
                print("No block found, planting")
                Farmer.plant()
            else
                if not block.state.age then
                    print("Block is not a plant")
                elseif block.state.age >= 7 then
                    print("Block is ready to harvest")
                    Farmer.Harvest(block)
                else
                    print("Block is not ready to harvest")
                end
            end
        end
        COORDS.MoveToCords(COORDS.X, COORDS.Y, older_z)
    end
    COORDS.MoveToCords(Farmer.START_POS.X, Farmer.START_POS.Y, Farmer.START_POS.Z)
    COORDS.turnToDirection(Farmer.DEFAULT_SIDE)
end

if not Typing.VerifyEnum(COORDS.DIRECTIONS, Farmer.DEFAULT_DIR) then
    print("Invalid direction: " .. Farmer.DEFAULT_DIR)
    return
end
if not Farmer.init() then
    print("Failed to initialize farmer")
    return
end
Farmer.planter()
--sleep for 50 seconds
while true do
    os.sleep(50)
    Farmer.planter()
end




