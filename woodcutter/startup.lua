farm_z_size = 2
farm_x_size = 12
farm_cardinal = 'north'
farm_direction = 'east'
direction_start = 'east'
farm_x_start = -151
farm_y_start = 74
farm_z_start = -70



COORDS = require("Coordinates")
COORDS.init()
if COORDS.X == 0 and COORDS.Y == 0 and COORDS.Z == 0 then
    COORDS.SaveCoordinates(farm_x_start, farm_y_start, farm_z_start, direction_start)
end
COORDS.LoadCoordinates()
shell.run('Woodcutter.lua '.. farm_x_size .. ' ' .. farm_z_size .. ' ' .. farm_cardinal .. ' ' .. farm_direction .. ' ' .. farm_x_start .. ' ' .. farm_y_start .. ' ' .. farm_z_start)