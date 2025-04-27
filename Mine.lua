turtle = turtle
shell = shell

-- Constantes e variáveis globais
COBBLESTONE_SLOT = 1
CHEST_SLOT = 2
TORCH_SLOT = 16
DIRECTION = "NORTH"
RETURN_COORDS = {X = 0, Y = 0, Z = 0}
CHEST_COORDS = {X = 0, Y = 0, Z = 0}
X, Y, Z = 0, 0, 0
BLOCKS_PER_TORCH = 8
CURRENT_BLOCKS_WITHOUT_TORCH = 8

PLACES_TO_LOOK = {}

-- Lista de materiais a serem descartados
NOT_ORES = {
    "minecraft:stone", "minecraft:gravel", "minecraft:dirt",
    "minecraft:andesite", "minecraft:diorite", "minecraft:granite",
    "minecraft:cobblestone", "minecraft:water", "minecraft:lava",
    "minecraft:air", "minecraft:bedrock", "minecraft:torch", "minecraft:wall_torch",
    "minecraft:bubble_column", "minecraft:flowing_water", "minecraft:flowing_lava",
}

-- Função auxiliar para verificar se um valor está em uma tabela
function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then return true end
    end
    return false
end

-- Funções de movimento com atualização de coordenadas
function move(direction)
    local success = false
    
    if direction == "forward" then
        turtle.dig()
        success = turtle.forward()
        if success then
            if DIRECTION == "NORTH" then Z = Z - 1
            elseif DIRECTION == "SOUTH" then Z = Z + 1
            elseif DIRECTION == "EAST" then X = X + 1
            elseif DIRECTION == "WEST" then X = X - 1
            end
        end
    elseif direction == "up" then
        turtle.digUp()
        success = turtle.up()
        if success then Y = Y + 1 end
    elseif direction == "down" then
        local inspectSuccess, block = turtle.inspectDown()
        print(block.name)
        if (inspectSuccess and block.name ~= "minecraft:wall_torch") then
            turtle.digDown()
        else
            print("Não pode quebrar, tem uma tocha")
        end
        success = turtle.down()
        if success then Y = Y - 1 end
    end
    
    return success
end

-- Funções de rotação otimizadas
function turnLeft()
    turtle.turnLeft()
    if DIRECTION == "NORTH" then DIRECTION = "WEST"
    elseif DIRECTION == "WEST" then DIRECTION = "SOUTH"
    elseif DIRECTION == "SOUTH" then DIRECTION = "EAST"
    elseif DIRECTION == "EAST" then DIRECTION = "NORTH"
    end
end

function turnRight()
    turtle.turnRight()
    if DIRECTION == "NORTH" then DIRECTION = "EAST"
    elseif DIRECTION == "EAST" then DIRECTION = "SOUTH"
    elseif DIRECTION == "SOUTH" then DIRECTION = "WEST"
    elseif DIRECTION == "WEST" then DIRECTION = "NORTH"
    end
end

-- Função otimizada para virar para uma direção específica
function turnToDirection(targetDirection)
    if DIRECTION == targetDirection then return end
    
    if (DIRECTION == "NORTH" and targetDirection == "EAST") or
       (DIRECTION == "EAST" and targetDirection == "SOUTH") or
       (DIRECTION == "SOUTH" and targetDirection == "WEST") or
       (DIRECTION == "WEST" and targetDirection == "NORTH") then
        turnRight()
    else
        turnLeft()
    end
    
    if DIRECTION ~= targetDirection then
        turnToDirection(targetDirection)
    end
end

-- Função para ir ao chão
function GoToGroundLevel()
    while not turtle.inspectDown() do
        move("down")
    end
    print("Chegou ao nível do chão. Camada atual: " .. Y)
end

-- Verificar se está na camada desejada
function IsInDeterminedRange()
    Y = tonumber(Y)
    camada_start = tonumber(camada_start)
    
    if Y == camada_start then
        return true
    elseif Y < camada_start then
        return "below"
    else
        return false
    end
end

-- Limpar o inventário mantendo apenas itens importantes
function FixInventory()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and i ~= COBBLESTONE_SLOT and i ~= TORCH_SLOT then
            if has_value(NOT_ORES, item.name) then
                print("Descartando " .. item.name .. " do slot " .. i)
                turtle.select(i)
                turtle.dropDown()
            else
                print("Mantendo item " .. item.name .. " no slot " .. i)
            end
        end
    end
end

-- Reabastecer a turtle
function MakeRefuel()
    local fuel_types = {"minecraft:coal", "minecraft:charcoal", "minecraft:oak_log"}
    local target_fuel = 100
    local current_fuel = turtle.getFuelLevel()
    
    if current_fuel >= target_fuel then
        print("Combustível suficiente: " .. current_fuel)
        return true
    end
    
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and has_value(fuel_types, item.name) then
            print("Usando " .. item.name .. " como combustível")
            turtle.select(i)
            
            print("Reabastecendo de " .. current_fuel .. " até " .. target_fuel)
            while turtle.getFuelLevel() < target_fuel do
                if not turtle.refuel(1) then
                    print("Falha ao reabastecer")
                    return false
                end
            end
            
            print("Reabastecido para: " .. turtle.getFuelLevel())
            return true
        end
    end
    
    print("AVISO: Combustível não encontrado!")
    return false
end

-- Criar escada em espiral para baixo
function BuildCircleStairway()
    turtle.digUp()
    turtle.digDown()
    move("down")
    turnRight()
    turtle.dig()
    move("forward")
    print("Construída escada em espiral. Nova camada: " .. Y)
end

-- Ir para camada específica
function GoToSpecificLayer(build_stars)
    while true do
        local status = IsInDeterminedRange()
        
        if status == true then
            print("Chegou à camada desejada: " .. Y)
            return
        elseif status == "below" then
            print("Abaixo da camada alvo. Subindo de " .. Y .. " para " .. camada_start)
            while IsInDeterminedRange() == "below" do
                move("up")
            end
            turtle.placeDown()
            return
        end

        if build_stars then
            BuildCircleStairway()
        else
            move("down")
        end

        FixInventory()
        MakeRefuel()
    end
end

-- Verificar se um bloco é minério
function IsOre(block)
    return block and block.name and not has_value(NOT_ORES, block.name)
end

-- Funções de mineração e verificação otimizadas
function MineAround(direction)
    local current_x, current_y, current_z = X, Y, Z
    local current_direction = DIRECTION
    
    if direction == "up" then
        move("up")
    elseif direction == "down" then
        move("down")
    else
        move("forward")
    end
    
    print("Minerando em: X=" .. X .. ", Y=" .. Y .. ", Z=" .. Z .. ", Direção=" .. DIRECTION)
    return VerifyAround()
end

-- Verificar se há minérios ao redor
function VerifyAround(place_to_look, should_return)
    if place_to_look == nil then
        place_to_look = {
            X = X,
            Y = Y,
            Z = Z,
            UP = false,
            DOWN = false,
            NORTH = false,
            EAST = false,
            WEST = false,
        }
        
        local place_to_look_id = #PLACES_TO_LOOK + 1
    
        PLACES_TO_LOOK[place_to_look_id] = place_to_look
    end


    if not place_to_look.NORTH then
        -- Verificar na frente
        local success, block = turtle.inspect()
        if success and IsOre(block) then
            print("Encontrado minério: " .. block.name)
            MineAround()
            return true
        end
        place_to_look.NORTH = true
    end
    

    if not place_to_look.WEST then
        -- Verificar à esquerda
        turnToDirection('WEST')
        success, block = turtle.inspect()
        if success and IsOre(block) then
            print("Encontrado minério: " .. block.name)
            MineAround()
            return true
        end
        place_to_look.WEST = true
        turnToDirection('NORTH')
    end
    
    if not place_to_look.EAST then
        -- Verificar à direita
        turnToDirection('EAST')
        success, block = turtle.inspect()
        if success and IsOre(block) then
            print("Encontrado minério: " .. block.name)
            MineAround()
            return true
        end
        place_to_look.EAST = true
        turnToDirection('NORTH')
    end
        

    if not place_to_look.DOWN then
        -- Verificar para baixo
        success, block = turtle.inspectDown()
        if success and IsOre(block) then
            print("Encontrado minério abaixo: " .. block.name)
            MineAround("down")
            return true
        end
        place_to_look.DOWN = true
    end
    

    if not place_to_look.UP then
        -- Verificar para cima
        success, block = turtle.inspectUp()
        if success and IsOre(block) then
            print("Encontrado minério acima: " .. block.name)
            MineAround("up")
            return true
        end
        place_to_look.UP = true
    end
    if not should_return then
        ReturnToCoordinates()
    end
    return false
end

function ReverseArray(ar)
    local reversed = {}
    for i = #ar, 1, -1 do
        table.insert(reversed, ar[i])
    end
    return reversed
end

-- Olha os lugares que não olhou todos os lados para verificar se tem minério
function LookOldPlaces()
    while #PLACES_TO_LOOK > 0 do
        local i = #PLACES_TO_LOOK  -- Começa pelo último elemento
        local selected_place = PLACES_TO_LOOK[i]
        if selected_place.NORTH and  
        selected_place.EAST and selected_place.WEST and 
        selected_place.UP and selected_place.DOWN then
         print("Verificado todos os lados")
         table.remove(PLACES_TO_LOOK, i)
        else
            print("Verificando lugar: " .. selected_place.X .. ", " .. selected_place.Y .. ", " .. selected_place.Z)
            
            while not ReturnToSpecificCoordinate(selected_place.X, selected_place.Y, selected_place.Z) do
                print("Retornando")
            end
            
            VerifyAround(selected_place, true)
            i = i - 1
        end      
    end
    
end

function ReturnToSpecificCoordinate(local_X,local_Y,local_Z)
    print("Local atual - X=" .. X .. ", Y=" .. Y .. ", Z=" .. Z)
    print("Local alvo - X=" .. local_X .. ", Y=" .. local_Y .. ", Z=" .. local_Z)
    if X < local_X then
        turnToDirection("EAST")
        move("forward")
    elseif X > local_X then
        turnToDirection("WEST")
        move("forward")
    elseif Z < local_Z then
        turnToDirection("SOUTH")
        move("forward")
    elseif Z > local_Z then
        turnToDirection("NORTH")
        move("forward")
    elseif Y < local_Y then
        move("up")
    elseif Y > local_Y then
        move("down")
    else
        turnToDirection("NORTH")
        print("Retorno concluído")
        return true
    end    
end


-- Função otimizada para retornar às coordenadas
function ReturnToCoordinates()
    LookOldPlaces()
    print("Retornando para: X=" .. RETURN_COORDS.X .. ", Y=" .. RETURN_COORDS.Y .. ", Z=" .. RETURN_COORDS.Z)
    
    while not ReturnToSpecificCoordinate(RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z) do
    end
end

-- Verificar baú e gerenciar itens
function VerifyChest()
    local success, block = turtle.inspect()
    return success and block.name == "quark:oak_chest"
end

-- Otimização da função de retorno ao baú
function ReturnToChest()
    print("Retornando para o baú: X=" .. CHEST_COORDS.X .. ", Y=" .. CHEST_COORDS.Y .. ", Z=" .. CHEST_COORDS.Z)
    
    -- Ajustar altura
    while Y < CHEST_COORDS.Y do move("up") end
    while Y > CHEST_COORDS.Y do move("down") end
    
    -- Ajustar X
    if X ~= CHEST_COORDS.X then
        turnToDirection(X < CHEST_COORDS.X and "EAST" or "WEST")
        while X ~= CHEST_COORDS.X do move("forward") end
    end
    
    -- Ajustar Z
    if Z ~= CHEST_COORDS.Z then
        turnToDirection(Z < CHEST_COORDS.Z and "SOUTH" or "NORTH")
        while Z ~= CHEST_COORDS.Z do move("forward") end
    end
end

-- Armazenar itens no baú
function StoreItems()
    print("Armazenando itens no baú")
    ReturnToChest()
    turnToDirection("SOUTH")
    
    if not VerifyChest() then
        print("Baú não encontrado. Retornando para a posição original.")
        ReturnToCoordinates()
        return false
    end
    
    turtle.refuel(64)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and i ~= COBBLESTONE_SLOT and i ~= TORCH_SLOT then
            print("Colocando " .. item.name .. " no baú")
            turtle.select(i)
            turtle.drop()
        end
    end
    
    turnToDirection("NORTH")
    print("Itens armazenados com sucesso")
    return true
end

-- Verificar se o inventário está cheio
function VerifyFullInventory()
    local used_inventorys = 0
    for i = 1, 16 do
        if turtle.getItemDetail(i) then
            used_inventorys = used_inventorys + 1
        end
    end
    if used_inventorys >= 15 then
        print("Inventário cheio. Total de slots usados: " .. used_inventorys)
        return true
    end

    return false
end


function PlaceSideBlock()
    local success, block = turtle.inspect()
    if not success then
        print("Colocando bloco lateral")
        turtle.place()
    elseif block.name == 'minecraft:air' then
        print("Colocando bloco lateral")
        turtle.place()
    elseif block.name == 'minecraft:water' then
        print("Colocando bloco lateral")
        turtle.place()
    elseif block.name == 'minecraft:flowing_water' then
        print("Colocando bloco lateral")
        turtle.place()
    elseif block.name == 'minecraft:lava' then
        print("Colocando bloco lateral")
        turtle.place()
    elseif block.name == 'minecraft:flowing_lava' then
        print("Colocando bloco lateral")
        turtle.place()
    end
end

function PlaceUpBlock()
    local success, block = turtle.inspectUp()
    if not success then
        print("Colocando bloco acima")
        turtle.placeUp()
    elseif block.name == 'minecraft:air' then
        print("Colocando bloco acima")
        turtle.placeUp()
    elseif block.name == 'minecraft:water' then
        print("Colocando bloco acima")
        turtle.placeUp()
    elseif block.name == 'minecraft:flowing_water' then
        print("Colocando bloco acima")
        turtle.placeUp()
    elseif block.name == 'minecraft:lava' then
        print("Colocando bloco acima")
        turtle.placeUp()
    elseif block.name == 'minecraft:flowing_lava' then
        print("Colocando bloco acima")
        turtle.placeUp()
    end
end

-- Função principal de mineração
function StripMine()
    local numbers_to_dig = tonumber(camada_end) - tonumber(camada_start)
    
    turtle.digUp()
    
    CHEST_COORDS.X = X
    CHEST_COORDS.Y = Y
    CHEST_COORDS.Z = Z
    print("Coordenadas do baú: X=" .. CHEST_COORDS.X .. ", Y=" .. CHEST_COORDS.Y .. ", Z=" .. CHEST_COORDS.Z)
    
    turnToDirection("SOUTH")
    turtle.select(CHEST_SLOT)
    turtle.place()
    turnToDirection("NORTH")
    print("Baú colocado na camada: " .. Y)
    
    if not StoreItems() then
        print("Falha ao armazenar itens. Abortando.")
        return false
    end

    while true do
        print("Direção atual: " .. DIRECTION)
        
        -- Salvar coordenadas atuais como ponto de retorno
        RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = X, Y, Z
        turnToDirection("NORTH")
        move("forward")

        CURRENT_BLOCKS_WITHOUT_TORCH = CURRENT_BLOCKS_WITHOUT_TORCH + 1
        RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = X, Y, Z
        
        -- Verificar minérios ao redor
        local verify_around = VerifyAround()

        -- Verificar minérios em todas as camadas
        print("Verificando " .. numbers_to_dig .. " camadas acima")
        for i = 1, numbers_to_dig do
            print("Verificando bloco " .. i .. " acima")
            move("up")
            
            -- Colocar tocha se necessário
            if CURRENT_BLOCKS_WITHOUT_TORCH >= BLOCKS_PER_TORCH and i == 1 then
                print("Colocando tocha")
                turtle.select(16)
                turnToDirection("EAST")
                turtle.dig()
                turtle.place()
                turnToDirection("NORTH")
                CURRENT_BLOCKS_WITHOUT_TORCH = 0
            end

            -- Salvar coordenadas e verificar minérios
            RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = X, Y, Z
            local verify_around = VerifyAround()
         
            -- Verificar e preencher espaços vazios nas laterais
            turtle.select(COBBLESTONE_SLOT)
            
            turnToDirection("EAST")
            PlaceSideBlock()

            turnToDirection("WEST")
            PlaceSideBlock()

            PlaceUpBlock()

            turnToDirection("NORTH")
        end

        -- Verificar e preencher espaço vazio acima
        turtle.select(COBBLESTONE_SLOT)
        if not turtle.inspectUp() then
            print("Não há bloco acima")
            turtle.placeUp()
        end
        
        -- Voltar para a camada original
        for i = 1, numbers_to_dig do
            move("down")
        end
        
        -- Manutenção
        GoToSpecificLayer(false)
        MakeRefuel()
        FixInventory()
        
        -- Verificar inventário cheio
        if VerifyFullInventory() then
            RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = X, Y, Z
            print("Inventário cheio. Retornando para o baú.")
            if not StoreItems() then
                print("Falha ao armazenar itens. Abortando.")
                return false
            end
            ReturnToCoordinates()
        end
    end
end

-- PROGRAMA PRINCIPAL
local first_slot_item = turtle.getItemDetail(COBBLESTONE_SLOT)
local chest_slot_item = turtle.getItemDetail(CHEST_SLOT)
local torch_slot_item = turtle.getItemDetail(TORCH_SLOT)

-- Verificação inicial de itens
if first_slot_item == nil then
    print("Nenhum item encontrado no slot " .. COBBLESTONE_SLOT)
    shell.exit()
elseif first_slot_item.name ~= "minecraft:cobblestone" then
    print("Item no slot " .. COBBLESTONE_SLOT .. " não é cobblestone")
    shell.exit()
elseif chest_slot_item == nil then
    print("Nenhum item encontrado no slot " .. CHEST_SLOT)
    shell.exit()
elseif chest_slot_item.name ~= "quark:oak_chest" then
    print("Item no slot " .. CHEST_SLOT .. " não é um baú")
    shell.exit()
elseif torch_slot_item == nil then
    print("Nenhum item encontrado no slot " .. TORCH_SLOT)
    shell.exit()
elseif torch_slot_item.name ~= "minecraft:torch" then
    print("Item no slot " .. TORCH_SLOT .. " não é uma tocha")
    shell.exit()
else
    print('Melhor camada para ferro é 15 até 18')
    
    write('Qual a camada para começar > ')
    camada_start = tonumber(read())
    
    write('Qual a camada para finalizar > ')
    camada_end = tonumber(read())
    
    while camada_start > camada_end do
        print('Camada inicial não pode ser maior que a camada final')
        write('Qual a camada para começar > ')
        camada_start = tonumber(read())
        
        write('Qual a camada para finalizar > ')
        camada_end = tonumber(read())
    end
    
    write('Qual a camada atual > ')
    Y = tonumber(read())
    
    print('Camada atual: ' .. Y)
    print('Camada inicial: ' .. camada_start)
    print('Camada final: ' .. camada_end)
    write('Pressione ENTER para continuar')
    read()
    
    -- Iniciar mineração
    GoToSpecificLayer(true)
    GoToGroundLevel()
    StripMine()
end