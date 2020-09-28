Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)

            fetch()

            local minigameState = get('minigameState')

            if     minigameState == 2 then
                
            elseif minigameState == 6 then 

                if IsControlJustPressed(0, GetHashKey('INPUT_SPRINT')) then
                    set('transitionFlag', 128)
                end

                local bobberEntity = get('bobberEntity')

                local hookEntity = get('hookEntity')
                local hookPosition = GetEntityCoords(hookEntity)
                
                local unk4 = get('unk4') 

                if get('distanceToHook') <= 4.0 then
                    if unk4 ~= 1.0 then
                        set('unk4', 1.0)
                    end
                else
                    if unk4 ~= 0.4 then
                        set('unk4', 0.4)
                    end
                end

                local fishEntity

                for _, nearbyFishEntity in ipairs(GetFishInRadius(hookPosition, 50.0)) do
                    local nFishPosition = GetEntityCoords(nearbyFishEntity)

                    TaskGoToEntity(nearbyFishEntity, hookEntity, 100, 1, 1.0, 2.0, 0);

                    local distanceToHook = #(hookPosition - nFishPosition)

                    if distanceToHook <= 1.6 then
                        fishEntity = nearbyFishEntity

                        break;
                    end
                end

                if fishEntity then

                    if get('unk1') == 1 then

                        local playerPed = PlayerPedId()

                        Citizen.InvokeNative(0xF0FBF193F1F5C0EA, fishEntity)
                        -- WATER::?

                        SetPedConfigFlag(fishEntity, 17, true)

                        Citizen.InvokeNative(0x1F298C7BD30D1240, playerPed)
                        -- TASK::?

                        ClearPedTasksImmediately(fishEntity, false, true)
                        TaskSetBlockingOfNonTemporaryEvents(fishEntity, true)

                        Citizen.InvokeNative(0x1A52076D26E09004, playerPed, fishEntity)
                        -- TASk::SET_FISHINGROD_HOOKED_ENTITY

                        set('fishEntity', fishEntity)

                        set('transitionFlag', 4)
                    end
                end
            elseif minigameState == 7 then
                
                if IsControlJustPressed(0, GetHashKey('INPUT_SPRINT')) then
                    set('transitionFlag', 11)
                end

                local horizontalMove = 0

                if GetControlNormal(0, GetHashKey('INPUT_RADIAL_MENU_NAV_LR')) > 0 then -- Right
                    horizontalMove = horizontalMove - (0.05 * GetControlNormal(0, 0x390948DC))
                end
                
                if GetControlNormal(0, GetHashKey('INPUT_RADIAL_MENU_NAV_LR')) < 0 then -- Left
                    horizontalMove = horizontalMove + (0.05 * -GetControlNormal(0, 0x390948DC))
                end

                if horizontalMove < 0 then
                    horizontalMove = 0
                end
                
                if horizontalMove > 1 then
                    horizontalMove = 1
                end

                set('rodPositionLR', horizontalMove)

                local unk4 = get('unk4') 

                if get('distanceToHook') <= 4.0 then
                    set('transitionFlag', 12)

                    if unk4 ~= 1.0 then
                        set('unk4', 1.0)
                    end
                else
                    if unk4 ~= 0.4 then
                        set('unk4', 0.4)
                    end
                end

                if IsControlJustPressed(0, GetHashKey('INPUT_ATTACK')) then
                    set('rodPositionUD', 0.6)
                end

                if IsControlJustReleased(0, GetHashKey('INPUT_ATTACK')) then
                    set('rodPositionUD', 0.0)
                end
                
            elseif minigameState == 12 then 

                if IsControlJustPressed(0, GetHashKey('INPUT_ATTACK')) then
                    set('transitionFlag', 32)
                end

                if IsControlJustPressed(0, GetHashKey('INPUT_AIM')) then
                    set('transitionFlag', 64)
                end

                if get('unk1') == 96 and get('transitionFlag') == 0 then                    
                    local fishEntity = get('fishEntity')

                    -- Maybe give an inventory item

                    --SetEntityVisible(fishEntity, false)
                    --SetEntityAsMissionEntity(fishEntity, true, true)
                    DeleteEntity(fishEntity)
                end
            end
        end
    end
)

function GetFishInRadius(center, radius)
    local r = {}

    local itemSet = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, center, radius, itemSet, 1, Citizen.ResultAsInteger())
    -- number xPos, number yPox, number zPos, float distance, int itemSet, int entityType

    if size > 0 then
        for index = 0, size - 1 do
            local entity = GetIndexedItemInItemset(index, itemSet)
            if GetEntityPopulationType(entity) == 6 and not IsPedDeadOrDying(entity, 0) then
                table.insert(r, entity)
            end
        end
    end

    if IsItemsetValid(itemSet) then
        DestroyItemset(itemSet)
    end

    return r
end

-- FOR TESTING PURPOSES

Citizen.CreateThread(
    function()

        local ped = PlayerPedId()

        Citizen.InvokeNative(0xB282DC6EBD803C75, ped, GetHashKey("WEAPON_FISHINGROD"), 500, true, 0);
        Citizen.InvokeNative(0x9B0C7FA063E67629, ped, "P_FINISHDCRAWDLEGENDARY01X", 0, 1)

        while true do
            Citizen.Wait(0)
    
            for i, struct_property in ipairs(struct) do        

                DrawScreenText(struct_property.name, 0.65, 0.05 + (i * 0.025), 0.4, 0.4, true, 247, 88, 20, 255, false);
                if struct_property.value then
                    DrawScreenText(struct_property.value .. "", 0.75, 0.05 + (i * 0.025), 0.4, 0.4, true, 247, 88, 20, 255, false);
                end
            end
        end
    end
)