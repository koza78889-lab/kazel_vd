-- language: LuaU, file: ofuscated_print.lua, target: Roblox / LuaU runtime
-- plaintext never lives as contiguous string in source

local enc = {
    139, 204, 140, 222, 142, 226, 177, 215, 179, 216, 69, 183,
    227, 184, 220, 186, 215, 188, 220, 190, 209, 160, 200
}

local function d()
    local key = 0x5A
    local t = {}
    for i, b in ipairs(enc) do
        t[i] = string.char(bit32.bxor(b, (key + i) % 256))
    end
    return table.concat(t)
end

print(d())
