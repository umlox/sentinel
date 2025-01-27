local function decode(str)
    -- Add your custom decoding logic here
    return str
end

local encrypted = "YOUR_ENCRYPTED_STRING"
local decoded = decode(encrypted)
local success, result = pcall(loadstring(decoded))
if success then
    return result
else
    warn("Failed to load script")
end
