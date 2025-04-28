Typing = {}
function Typing.VerifyEnum(table, input)
    if table[input] then
        return input
    end
    
    for k, v in pairs(table) do
        if v == input then
            return input
        end
    end
    
    return nil
end
return Typing