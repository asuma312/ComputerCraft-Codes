require('Typing')
local json = require('json')
local http = http
DataSaver = {}
DataSaver.base_url = 'http://localhost:8080'
DataSaver.urls = {
    save_data = '/turtle/save_data'
}


function DataSaver:SaveData(turtle_name, information)
    local payload_data = {
        turtle_name = turtle_name,
        information = information
    }
    local payload = json.encode(payload_data)
    local response = http.post(self.base_url .. self.urls.save_data, payload, {
        ['Content-Type'] = 'application/json'
    })
    if response then
        local response_data = response.readAll()
        response.close()
        local data = json.decode(response_data)
        if data.success then
            print("Data saved successfully")
            return true
        else
            print("Failed to save data: " .. data.message)
            return false
        end
    else
        print("Failed to connect to server")
        return false
    end
end


return DataSaver