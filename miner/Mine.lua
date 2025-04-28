require("Coordinates")
turtle = turtle
shell = shell

-- Constantes e variáveis globais
COBBLESTONE_SLOT = 1
CHEST_SLOT = 2
TORCH_SLOT = 16
CHUNK_LOADERS_SLOT = 3
RETURN_COORDS = {X = 0, Y = 0, Z = 0}
CHEST_COORDS = {X = 0, Y = 0, Z = 0}
CHUNK_LOADER_COORDS = {X = 0, Y = 0, Z = 0}
BLOCKS_PER_TORCH = 8
CURRENT_BLOCKS_WITHOUT_TORCH = 8

CHUNK_LOADER_BLOCKS = 20
CURRENT_CHUNK_LOADER_BLOCKS = 20

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

-- As funções de movimento e rotação agora são providas por Coordinates.lua:
-- Use COORDS.move(direction), COORDS.turnLeft(), COORDS.turnRight(), COORDS.turnToDirection(direction)

-- Função para ir ao chão
function GoToGroundLevel()
    while not turtle.inspectDown() do
        COORDS.move(COORDS.MOVEMENTS.DOWN)
    end
    print("Chegou ao nível do chão. Camada atual: " .. COORDS.Y)
end

-- Verificar se está na camada desejada
function IsInDeterminedRange()
    COORDS.Y = tonumber(COORDS.Y)
    camada_start = tonumber(camada_start)
    
    if COORDS.Y == camada_start then
        return true
    elseif COORDS.Y < camada_start then
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
    --1 stack de carvao é 5250, 5500 é uma medida aceitavel pra n desperdiçar combustivel
    local target_fuel = turtle.getFuelLimit() - 5500
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
            local item_count = turtle.getItemCount()
            
            print("Reabastecendo de " .. current_fuel .. " até " .. target_fuel)
            while turtle.getFuelLevel() < target_fuel do
                if not turtle.refuel(item_count) then
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
    COORDS.move(COORDS.MOVEMENTS.DOWN)
    COORDS.turnRight()
    turtle.dig()
    COORDS.move(COORDS.MOVEMENTS.FORWARD)
    print("Construída escada em espiral. Nova camada: " .. COORDS.Y)
end

-- Ir para camada específica
function GoToSpecificLayer(build_stars)
    while true do
        local status = IsInDeterminedRange()
        
        if status == true then
            print("Chegou à camada desejada: " .. COORDS.Y)
            return
        elseif status == "below" then
            print("Abaixo da camada alvo. Subindo de " .. COORDS.Y .. " para " .. camada_start)
            while IsInDeterminedRange() == "below" do
                COORDS.move(COORDS.MOVEMENTS.UP)
            end
            turtle.placeDown()
            return
        end

        if build_stars then
            BuildCircleStairway()
        else
            COORDS.move(COORDS.MOVEMENTS.DOWN)
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
    local current_x, current_y, current_z = COORDS.X, COORDS.Y, COORDS.Z
    local current_direction = COORDS.DIRECTION
    
    if direction == "up" then
        COORDS.move(COORDS.MOVEMENTS.UP)
    elseif direction == "down" then
        COORDS.move(COORDS.MOVEMENTS.DOWN)
    else
        COORDS.move(COORDS.MOVEMENTS.FORWARD)
    end
    
    print("Minerando em: X=" .. COORDS.X .. ", Y=" .. COORDS.Y .. ", Z=" .. COORDS.Z .. ", Direção=" .. COORDS.DIRECTION)
    return VerifyAround()
end

-- Verificar se há minérios ao redor
function VerifyAround(place_to_look, should_return)
    if place_to_look == nil then
        place_to_look = {
            X = COORDS.X,
            Y = COORDS.Y,
            Z = COORDS.Z,
            UP = false,
            DOWN = false,
            NORTH = false,
            EAST = false,
            WEST = false,
            SOUTH = false,
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
        COORDS.turnToDirection(COORDS.DIRECTIONS.WEST)
        success, block = turtle.inspect()
        if success and IsOre(block) then
            print("Encontrado minério: " .. block.name)
            MineAround()
            return true
        end
        place_to_look.WEST = true
        COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
    end
    
    if not place_to_look.EAST then
        -- Verificar à direita
        COORDS.turnToDirection(COORDS.DIRECTIONS.EAST)
        success, block = turtle.inspect()
        if success and IsOre(block) then
            print("Encontrado minério: " .. block.name)
            MineAround()
            return true
        end
        place_to_look.EAST = true
        COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
    end

    if not place_to_look.SOUTH then
        -- Verificar atrásx
        COORDS.turnToDirection(COORDS.DIRECTIONS.SOUTH)
        success, block = turtle.inspect()
        if success and IsOre(block) then
            print("Encontrado minério: " .. block.name)
            MineAround()
            return true
        end
        place_to_look.SOUTH = true
        COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
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
        selected_place.UP and selected_place.DOWN and selected_place.SOUTH
        then
         print("Verificado todos os lados")
         table.remove(PLACES_TO_LOOK, i)
        else
            print("Verificando lugar: " .. selected_place.X .. ", " .. selected_place.Y .. ", " .. selected_place.Z)
            
            COORDS.MoveToCords(selected_place.X, selected_place.Y, selected_place.Z) do
            
            VerifyAround(selected_place, true)
            i = i - 1
        end      
    end
end
    
end


-- Função otimizada para retornar às coordenadas
function ReturnToCoordinates()
    LookOldPlaces()
    print("Retornando para: X=" .. RETURN_COORDS.X .. ", Y=" .. RETURN_COORDS.Y .. ", Z=" .. RETURN_COORDS.Z)
    
    COORDS.MoveToCords(RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z)
    
end

-- Verificar baú e gerenciar itens
function VerifyChest()
    local success, block = turtle.inspect()
    return success and block.name ==  "enderchests:ender_chest"
end

-- Otimização da função de retorno ao baú
function ReturnToChest()
    print("Retornando para o baú: X=" .. CHEST_COORDS.X .. ", Y=" .. CHEST_COORDS.Y .. ", Z=" .. CHEST_COORDS.Z)
    
    -- Ajustar altura
    while COORDS.Y < CHEST_COORDS.Y do COORDS.move(COORDS.MOVEMENTS.UP) end
    while COORDS.Y > CHEST_COORDS.Y do COORDS.move(COORDS.MOVEMENTS.DOWN) end
    
    -- Ajustar X
    if COORDS.X ~= CHEST_COORDS.X then
        COORDS.turnToDirection(COORDS.X < CHEST_COORDS.X and COORDS.DIRECTIONS.EAST or COORDS.DIRECTIONS.WEST)
        while COORDS.X ~= CHEST_COORDS.X do COORDS.move(COORDS.MOVEMENTS.FORWARD) end
    end
    
    -- Ajustar Z
    if COORDS.Z ~= CHEST_COORDS.Z then
        COORDS.turnToDirection(COORDS.Z < CHEST_COORDS.Z and COORDS.DIRECTIONS.SOUTH or COORDS.DIRECTIONS.NORTH)
        while COORDS.Z ~= CHEST_COORDS.Z do COORDS.move(COORDS.MOVEMENTS.FORWARD) end
    end
end

-- Armazenar itens no baú
function StoreItems()
    print("Armazenando itens no baú")
    COORDS.turnToDirection(COORDS.DIRECTIONS.SOUTH)
    turtle.select(CHEST_SLOT)
    turtle.place()
    
    if not VerifyChest() then
        print("Baú não encontrado. Retornando para a posição original.")
        ReturnToCoordinates()
        return false
    end
    
    turtle.refuel(64)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and i ~= COBBLESTONE_SLOT and i ~= TORCH_SLOT and i~=CHUNK_LOADERS_SLOT then
            print("Colocando " .. item.name .. " no baú")
            turtle.select(i)
            turtle.drop()
        end
    end

    turtle.dig()

    for i=1, 16 do 
        local item = turtle.getItemDetail(i)
        if item then 
            if item.name == 'enderchests:ender_chest' then 
                turtle.select(i)
                local count = turtle.getItemCount()
                turtle.transferTo(CHEST_SLOT, count)
                break
            end
        end
    end
    
    COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
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
    elseif block.name ~= 'minecraft:wall_torch' and block.name ~= 'weirdinggadget:weirding_gadget' then
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


function VerifyChunkLoader()
    if CURRENT_CHUNK_LOADER_BLOCKS >= CHUNK_LOADER_BLOCKS then
        return true
    end
    return false
end

function SetupChunkLoader(is_first_time)
    if not VerifyChunkLoader() then
        return
    end
    RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = COORDS.X, COORDS.Y, COORDS.Z

    local temp_x = COORDS.X
    local temp_y = COORDS.Y
    local temp_z = COORDS.Z

    turtle.select(CHUNK_LOADERS_SLOT)
    COORDS.turnToDirection(COORDS.DIRECTIONS.EAST)
    turtle.dig()
    turtle.place()
    CURRENT_CHUNK_LOADER_BLOCKS = 0

    if is_first_time then
        CHUNK_LOADER_COORDS.X = temp_x
        CHUNK_LOADER_COORDS.Y = temp_y
        CHUNK_LOADER_COORDS.Z = temp_z
        return
    end

    COORDS.MoveToCords(CHUNK_LOADER_COORDS.X, CHUNK_LOADER_COORDS.Y, CHUNK_LOADER_COORDS.Z)
    COORDS.turnToDirection(COORDS.DIRECTIONS.EAST)
    turtle.dig()
    for i=1, 16 do
        slot = turtle.getItemDetail(i)
        if not slot then
            print("Sem item")
        elseif slot.name == 'weirdinggadget:weirding_gadget' then
            turtle.select(i)
            count = turtle.getItemCount()
            turtle.transferTo(CHUNK_LOADERS_SLOT,count)
            break
        end
    end
    
    COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
    ReturnToCoordinates()

    CHUNK_LOADER_COORDS.X = temp_x
    CHUNK_LOADER_COORDS.Y = temp_y
    CHUNK_LOADER_COORDS.Z = temp_z

end

-- Função principal de mineração
function StripMine()
    local numbers_to_dig = tonumber(camada_end) - tonumber(camada_start)
    
    turtle.digUp()
    
    CHEST_COORDS.X = COORDS.X
    CHEST_COORDS.Y = COORDS.Y
    CHEST_COORDS.Z = COORDS.Z
    print("Coordenadas do baú: X=" .. CHEST_COORDS.X .. ", Y=" .. CHEST_COORDS.Y .. ", Z=" .. CHEST_COORDS.Z)
    
    if not StoreItems() then
        print("Falha ao armazenar itens. Abortando.")
        return false
    end
    SetupChunkLoader(true)

    while true do
        print("Direção atual: " .. COORDS.DIRECTION)
    
        -- Salvar coordenadas atuais como ponto de retorno
        RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = COORDS.X, COORDS.Y, COORDS.Z
        COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
        COORDS.move(COORDS.MOVEMENTS.FORWARD)

        CURRENT_BLOCKS_WITHOUT_TORCH = CURRENT_BLOCKS_WITHOUT_TORCH + 1
        CURRENT_CHUNK_LOADER_BLOCKS = CURRENT_CHUNK_LOADER_BLOCKS + 1
        RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = COORDS.X, COORDS.Y, COORDS.Z
        
        -- Verificar minérios ao redor
        local verify_around = VerifyAround()

        -- Verificar minérios em todas as camadas
        print("Verificando " .. numbers_to_dig .. " camadas acima")
        for i = 1, numbers_to_dig do
            print("Verificando bloco " .. i .. " acima")
            COORDS.move(COORDS.MOVEMENTS.UP)
            
            -- Colocar tocha se necessário
            if CURRENT_BLOCKS_WITHOUT_TORCH >= BLOCKS_PER_TORCH and i == 1 then
                print("Colocando tocha")
                turtle.select(16)
                COORDS.turnToDirection(COORDS.DIRECTIONS.EAST)
                turtle.dig()
                turtle.place()
                COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
                CURRENT_BLOCKS_WITHOUT_TORCH = 0
            end

            -- Salvar coordenadas e verificar minérios
            RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = COORDS.X, COORDS.Y, COORDS.Z
            local verify_around = VerifyAround()
         
            -- Verificar e preencher espaços vazios nas laterais
            turtle.select(COBBLESTONE_SLOT)
            
            COORDS.turnToDirection(COORDS.DIRECTIONS.EAST)
            PlaceSideBlock()

            COORDS.turnToDirection(COORDS.DIRECTIONS.WEST)
            PlaceSideBlock()
            if i == numbers_to_dig then
                PlaceUpBlock()
            end
            COORDS.turnToDirection(COORDS.DIRECTIONS.NORTH)
        end

        -- Verificar e preencher espaço vazio acima
        turtle.select(COBBLESTONE_SLOT)
        if not turtle.inspectUp() then
            print("Não há bloco acima")
            turtle.placeUp()
        end
        
        -- Voltar para a camada original
        for i = 1, numbers_to_dig do
            COORDS.move(COORDS.MOVEMENTS.DOWN)
        end
        
        -- Manutenção
        GoToSpecificLayer(false)
        MakeRefuel()
        FixInventory()
        
        -- Verificar inventário cheio
        if VerifyFullInventory() then
            RETURN_COORDS.X, RETURN_COORDS.Y, RETURN_COORDS.Z = COORDS.X, COORDS.Y, COORDS.Z
            print("Inventário cheio. Retornando para o baú.")
            if not StoreItems() then
                print("Falha ao armazenar itens. Abortando.")
                return false
            end
            ReturnToCoordinates()
        end
        SetupChunkLoader()
    end
end

-- PROGRAMA PRINCIPAL
local first_slot_item = turtle.getItemDetail(COBBLESTONE_SLOT)
local chest_slot_item = turtle.getItemDetail(CHEST_SLOT)
local torch_slot_item = turtle.getItemDetail(TORCH_SLOT)
local chunk_loader_slot = turtle.getItemDetail(CHUNK_LOADERS_SLOT)

-- Verificação inicial de itens
if first_slot_item == nil then
    print("Nenhum item encontrado no slot " .. COBBLESTONE_SLOT)
elseif first_slot_item.name ~= "minecraft:cobblestone" then
    print("Item no slot " .. COBBLESTONE_SLOT .. " não é cobblestone")
elseif chest_slot_item == nil then
    print("Nenhum item encontrado no slot " .. CHEST_SLOT)
elseif chest_slot_item.name ~= "enderchests:ender_chest" then
    print("Item no slot " .. CHEST_SLOT .. " não é um baú")
elseif torch_slot_item == nil then
    print("Nenhum item encontrado no slot da tocha(16)")
elseif torch_slot_item.name ~= "minecraft:torch" then
    print("Item no slot " .. TORCH_SLOT .. " não é uma tocha")
elseif chunk_loader_slot == nil then
    print("Nenhum item encontrado no slot do Chunk loader(3)")
elseif chunk_loader_slot.name ~= "weirdinggadget:weirding_gadget" then
    print()
    print("O item no slot 3 não é um chunk loader")
elseif turtle.getItemCount(CHUNK_LOADERS_SLOT) < 2 then
    print("Precisa ter no minimo 2 chunk loaders pra funcionar")
    
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
    COORDS.Y = tonumber(read())

    print('Camada atual: ' .. COORDS.Y)
    print('Camada inicial: ' .. camada_start)
    print('Camada final: ' .. camada_end)
    write('Pressione ENTER para continuar')
    read()
    
    -- Iniciar mineração
    GoToSpecificLayer(true)
    GoToGroundLevel()
    StripMine()
end