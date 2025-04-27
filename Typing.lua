Typing = {}
function Typing.VerifyEnum(table,key)
    -- Check if the value is in the enum table
    if table[key] then
        return key
    end
    return nil
end

return Typing