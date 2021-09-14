
local RGB = {}

function RGB.toLove(r,g,b,a)
    local a = a or 1
    return {r/225, g/225, b/225, a}
end

function RGB.mix(c1, c2)
    c1[4] = c1[4] or 1
    c2[4] = c2[4] or 1
    return {
        (c1[1] + c2[1]) / 2, 
        (c1[2] + c2[2]) / 2,
        (c1[3] + c2[3]) / 2,
        (c1[4] + c2[4]) / 2,
    }
end

return RGB