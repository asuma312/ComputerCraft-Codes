farm_z_size = 12
farm_x_size = 5
farm_cardinal = 'south'
farm_direction = 'west'
direction_start = 'west'
farm_x_start = -151
farm_y_start = 71
farm_z_start = -66

COORDS = require("Coordinates")
COORDS.init()
if COORDS.X == 0 and COORDS.Y == 0 and COORDS.Z == 0 then
    COORDS.SaveCoordinates(farm_x_start, farm_y_start, farm_z_start, direction_start)
end
shell.run('Farmer.lua '.. farm_x_size .. ' ' .. farm_z_size .. ' ' .. farm_cardinal .. ' ' .. farm_direction .. ' ' .. farm_x_start .. ' ' .. farm_y_start .. ' ' .. farm_z_start)