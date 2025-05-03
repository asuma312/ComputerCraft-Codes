astar = require('astar')
require('Coordinates')
start_dir = 'west'

COORDS.SaveCoordinates(
    -158,
    68,
    -68,
    start_dir
)
COORDS.init()
Logistics = {}
Logistics.end_coords = {
    X=-152,
    Y=74,
    Z=-70
}
local path = astar:doPathFinding(COORDS.getPosition(), Logistics.end_coords)

while COORDS.X ~= Logistics.end_coords.X or COORDS.Y ~= Logistics.end_coords.Y or COORDS.Z ~= Logistics.end_coords.Z do
    if path == nil then
        break
    end
    os.sleep(1)
    COORDS.MoveToCords(path.X, path.Y, path.Z)
    path = astar:getNextPath()
end