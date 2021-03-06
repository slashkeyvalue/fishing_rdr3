function dataview_type_from_property_type(view, propertyType)
    if     propertyType == 'i32' then
        return view.GetInt32
    elseif propertyType == 'f32' then
        return view.GetFloat32
    end
end

function float32_to_int32(num)
    local _view = DataView.ArrayBuffer(16)
    
    _view:SetFloat32(0, num, false);

    return _view:GetInt32(0);
end

struct = {
    --{
    --    name      = 'placeholder',
    --    type      = 'i32',
    --    value     = nil,
    --},   
    { -- 0
        name  = 'minigameState',
        type  = 'i32',
    },
    { -- 1
        name  = 'throwingDistance', 
        type  = 'f32',
    },
    { -- 2
        name  = 'distanceToHook',
        type  = 'f32',
    },
    { -- 3
        name  = 'lineCurvature',
        type  = 'f32',
    },
    { -- 4
        name  = 'unk',
        type  = 'f32',
    },
    { -- 5
        name  = 'unk1',
        type  = 'i32',
    },
    { -- 6
        name  = 'transitionFlag',
        type  = 'i32',
    },
    { -- 7
        name  = 'fishEntity',
        type  = 'i32',
    },
    { -- 8
        name  = 'unk2',
        type  = 'f32',
    },
    { -- 9
        name  = 'unk3',
        type  = 'f32',
    },
    { -- 10
        name  = 'scriptTimer',
        type  = 'i32',
    },
    { -- 11
        name  = 'hookEntity',
        type  = 'i32',
    },
    { -- 12
        name  = 'bobberEntity',
        type  = 'i32',
    },
    { -- 13
        name  = 'lineShake',
        type  = 'f32',
    },
    { -- 14
        name  = 'unk4',
        type  = 'f32',
    },
    { -- 15
        name  = 'unk5',
        type  = 'f32',
    },
    { -- 16
        name  = 'unk6',
        type  = 'i32',
    },
    { -- 17
        name  = 'unk7',
        type  = 'f32',
    },
    { -- 18
        name  = 'rodWeight',
        type  = 'i32',
    },
    { -- 19
        name  = 'unk8',
        type  = 'f32',
    },
    { -- 20
        name  = 'unk9',
        type  = 'f32',
    },
    { -- 21
        name  = 'lineShake2',
        type  = 'f32',
    },
    { -- 22
        name  = 'rodPositionLR',
        type  = 'f32',
    },
    { -- 23
        name  = 'rodPositionUD',
        type  = 'f32',
    },
    { -- 24
        name  = 'unk10',
        type  = 'f32',
    },
    { -- 25
        name  = 'unk11',
        type  = 'f32',
    },
    { -- 26
        name  = 'unk12',
        type  = 'f32',
    },
    { -- 27
        name  = 'unk13',
        type  = 'f32',
    },
}

local view = DataView.ArrayBuffer(256)

function fetch()
    Citizen.InvokeNative(0xF3735ACD11ACD500, PlayerPedId(), view:Buffer(), Citizen.ReturnResultAnyway());

    for i, struct_property in ipairs(struct) do        

        local byte = (i - 1) * 8

        local value

        if     struct_property.type == 'i32' then
            value = view:GetInt32(byte)
        elseif struct_property.type == 'f32' then
            value = view:GetFloat32(byte)
        end

        struct[i].value = value
    end
end

function flush()
    for i, struct_property in ipairs(struct) do        
        struct[i].value = nil
    end
end

function update(updated_property_name)
    for i, struct_property in ipairs(struct) do
        if struct_property.name == updated_property_name then

            local byte = (i - 1) * 8

            local value = struct_property.value

            local int32 = value

            if struct_property.type == 'f32' then
                int32 = float32_to_int32(value)
            end

            view:SetInt32(byte, int32)

            break
        end
    end

    Citizen.InvokeNative("0xF3735ACD11ACD501", PlayerPedId(), view:Buffer());
end

function find(property)
    for i, struct_property in ipairs(struct) do
        if struct_property.name == property then
            return struct_property
        end 
    end
end

function get(property)
    local struct_property = find(property)

    if struct_property then
        return struct_property.value
    end
end

function set(property, new_value)
    local struct_property = find(property)

    if struct_property then
        struct_property.value = new_value

        update(struct_property.name)
    end
end