require("Coordinates")
Storager = {}


Storager.storages = {
    sapling={
        X=-156,Y=68,Z=-67,DIRECTION=COORDS.DIRECTIONS.EAST,
    },
    ore= {
        X=-156,Y=68,Z=-66,DIRECTION=COORDS.DIRECTIONS.EAST,
    },
    others = {
        X=-158,Y=68,Z=-64,DIRECTION=COORDS.DIRECTIONS.WEST,
    }
}

Storager.suck_position = {
    X=-156,Y=68,Z=-70,DIRECTION='down',
}

Storager.ender_chest = {
    X=-156,Y=68,Z=-70,DIRECTION=COORDS.DIRECTIONS.EAST,
}

COAL_SLOT = 1


function Storager.get_in_list(item_name, table)
    item_name = item_name:gsub(":"," ")
    item_name = item_name:gsub("_"," ")
    for k, v in pairs(table) do
        local k_string = tostring(k)
        print("Checking " .. k_string .. " against " .. item_name)
        print(string.find(k_string,item_name))
        if string.find(item_name,k_string) then
            return v
        end
    end
    return nil
end

function Storager.refuel()
    turtle.select(COAL_SLOT)
    print('aa')
    while turtle.getFuelLevel() < 1000 do
        print("Refueling...")
        turtle.refuel(64)
    end
end


function Storager.initialize()
    -- Salva a posição inicial
    COORDS.SaveCoordinates()
    print("Posição inicial salva: ", 
          "X="..COORDS.X, 
          "Y="..COORDS.Y, 
          "Z="..COORDS.Z, 
          "DIR="..COORDS.DIRECTION)
end

function Storager.suck_items()
    COORDS.MoveToCords(Storager.suck_position.X, Storager.suck_position.Y, Storager.suck_position.Z)
    for i=1, 10 do
        turtle.suckDown()
    end
    COORDS.MoveToCords(Storager.ender_chest.X, Storager.ender_chest.Y, Storager.ender_chest.Z)
    COORDS.turnToDirection(Storager.ender_chest.DIRECTION)
    for i=1, 3*3 do
        turtle.suck()
    end
end


function Storager.store_items()
    
    for i=1, 16 do
        local item = turtle.getItemDetail(i)
        if item then
            print("Storing " .. item.name .. " in slot " .. i)
            turtle.select(i)
            local storage_item = Storager.get_in_list(item.name, Storager.storages)
            if not storage_item then
                storage_item = Storager.storages.others
            end
            print("Storing in " .. storage_item.X .. "," .. storage_item.Y .. "," .. storage_item.Z)
            COORDS.MoveToCords(storage_item.X, storage_item.Y, storage_item.Z)
            COORDS.turnToDirection(storage_item.DIRECTION)
            turtle.drop()
        end
    end
    COORDS.MoveToCords(Storager.start_position.X, Storager.start_position.Y, Storager.start_position.Z)
    COORDS.turnToDirection(Storager.start_position.DIRECTION)
end


START_X = tonumber(arg[1]) or -157
START_Y = tonumber(arg[2]) or 68
START_Z = tonumber(arg[3]) or -70
START_DIRECTION = arg[4] or COORDS.DIRECTIONS.EAST
Storager.refuel()

Storager.start_position = {X=START_X,Y=START_Y,Z=START_Z,DIRECTION=START_DIRECTION}
COORDS.MoveToCords(Storager.start_position.X, Storager.start_position.Y, Storager.start_position.Z)
COORDS.turnToDirection(Storager.start_position.DIRECTION)

while true do
    Storager.refuel()

    Storager.initialize()
    Storager.suck_items()
    Storager.store_items()
    os.sleep(50)
end