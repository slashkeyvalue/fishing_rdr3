function DrawScreenText(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, 'LITERAL_STRING', str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then
        SetTextDropshadow(1, 0, 0, 0, 255)
    end
    Citizen.InvokeNative(0xADA9255D, 4)
    DisplayText(str, x, y)
end

function DrawLine(vecA, vecB, r, g, b, a)
    Citizen.InvokeNative(GetHashKey('DRAW_LINE') & 0xFFFFFFFF, vecA, vecB, r, g, b, a)
end

function math.lerp(a,b,t) return a + (b - a) * t end