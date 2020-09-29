local g_fishSearchRadius = 50.0

local g_knownFishs = {}

local g_timerLastFishLuring = 0

local g_fishWeight = 0
local g_fishForce = 0
local g_fishTiredness = 0.0
local g_fishIsFighting = false
local g_fishIsJumping = false

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)

            -- FOR DEBUGGING
            DrawStructOnScreen()

            local playerPed = PlayerPedId()

            local minigameState = get('minigameState')
            local retval, weaponHash = GetCurrentPedWeapon(playerPed, false, 0, false)

            if weaponHash ~= GetHashKey('WEAPON_FISHINGROD') then
                if minigameState then
                    flush()
                end
            else
                fetch()

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

                    local rndCenter = hookPosition + vec3(math.random(65) - 65, math.random(85) - 85, 0.0)

                    local retval, waterHeight = _TestVerticalProbeAgainstAllWater(rndCenter)

                    rndCenter = vec3(rndCenter.xy, waterHeight)

                    for _, knownFishEntity in ipairs(g_knownFishs) do

                        if #(GetEntityCoords(knownFishEntity) - rndCenter) > g_fishSearchRadius then
                            SetBlockingOfNonTemporaryEvents(fishEntity, false)
                            TaskAnimalUnalerted(fishEntity, -1, 0, 0, 0)
                        end
                    end

                    g_knownFishs = {}

                    if (GetGameTimer() - g_timerLastFishLuring) > 1500 then
                        for _, nearbyFishEntity in ipairs(GetFishInRadius(hookPosition, g_fishSearchRadius)) do
                            local nFishPosition = GetEntityCoords(nearbyFishEntity)
                        
                            local shouldLure = math.random() > 0.75

                            if shouldLure then
                                ClearPedTasks(nearbyFishEntity, 1, 0)
                                SetBlockingOfNonTemporaryEvents(fishEntity, true)
                                TaskGoToEntity(nearbyFishEntity, hookEntity,  -1, 0.1, 3.0, 0.1, 1);

                                table.insert(g_knownFishs, nearbyFishEntity)

                                local distanceToHook = #(hookPosition - nFishPosition)

                                if distanceToHook <= 1.6 then
                                    fishEntity = nearbyFishEntity
    
                                    break;
                                end
                            else
                                TaskAnimalUnalerted(fishEntity, -1, 0, 0, 0)
                            end
                        end

                        g_timerLastFishLuring = GetGameTimer()
                    end

                    if fishEntity then

                        if get('unk1') == 1 then
                            
                            for _, knownFishEntity in ipairs(g_knownFishs) do
                                if #(GetEntityCoords(knownFishEntity) - rndCenter) > g_fishSearchRadius then
                                    SetBlockingOfNonTemporaryEvents(fishEntity, false)
                                    TaskAnimalUnalerted(fishEntity, -1, 0, 0, 0)
                                end
                            end
                            g_knownFishs = {}

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

                            ComputeFishWeight()

                            set('transitionFlag', 4)
                        end
                    end
                elseif minigameState == 7 then

                    if IsControlJustPressed(0, GetHashKey('INPUT_SPRINT')) then
                        set('transitionFlag', 11)
                    end

                    local isLeftClickPressed = IsControlPressed(0, GetHashKey('INPUT_ATTACK'));
                    local isRightClickPressed = IsControlPressed(0, GetHashKey('INPUT_AIM'));

                    local rodPositionLR = isRightClickPressed and 1.0 - GetControlNormal(0, GetHashKey('INPUT_CURSOR_X')) or -1.0
                    local rodPositionUD = isRightClickPressed and 1.0 - GetControlNormal(0, GetHashKey('INPUT_CURSOR_Y')) or -1.0
                    
                    set('rodPositionLR', rodPositionLR)
                    set('rodPositionUD', rodPositionUD)

                    local unk4 = get('unk4') 

                    local rodForce = math.lerp(math.abs(rodPositionLR), math.abs(rodPositionUD), 0.5)

                    local fishEntity = get('fishEntity')

                    if not g_fishIsFighting then
                        if g_fishTiredness <= 0 then
                            g_fishForce = math.random() * g_fishWeight

                            --print('fish force == ' , g_fishForce, g_fishWeight)

                            g_fishIsFighting = true
                        else
                            g_fishTiredness = g_fishTiredness - 0.001
                        end
                    else
                        g_fishTiredness = g_fishTiredness + 0.001

                        if g_fishTiredness >= 1.0 then
                            g_fishTiredness = 1.0
                            g_fishForce = 0.0

                            --print('fish is now tired')

                            g_fishIsFighting = false
                        end
                    end

                    local tension = g_fishForce / g_fishWeight

                    local fishHeading = GetEntityHeading(fishEntity)
                    local playerHeading = GetEntityHeading(playerPed)

                    local diffHeading = (fishHeading - playerHeading)

                    if diffHeading < 0.0 then
                        difHeading = diffHeading + 360.0
                    end

                    local rodWeight = 3

                    if diffHeading >= 180.0 or isLeftClickPressed then
                        rodWeight = 4
                    end

                    tension = tension + ( (g_fishWeight * 0.1) / g_fishWeight)

                    set('lineShake', tension)
                    set('rodWeight', rodWeight)  

                    if get('distanceToHook') <= 4.0 then
                        set('transitionFlag', 12)
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

    --if IsItemsetValid(itemSet) then
        DestroyItemset(itemSet)
    --end

    return r
end

function ModelToWeightIndex(fishEntity)

    local model = GetEntityModel(fishEntity)

    if model == GetHashKey("A_C_FISHBLUEGIL_01_SM") or model == GetHashKey("A_C_FISHBLUEGIL_01_MS") then
        return 0
    elseif model == GetHashKey("A_C_FISHBULLHEADCAT_01_MS") or model == GetHashKey("A_C_FISHBULLHEADCAT_01_SM") then
        return 1
    elseif model == GetHashKey("A_C_FISHCHAINPICKEREL_01_MS") or model == GetHashKey("A_C_FISHCHAINPICKEREL_01_SM") then
        return 2
    elseif model == GetHashKey("A_C_FISHCHANNELCATFISH_01_XL") or model == GetHashKey("A_C_FISHCHANNELCATFISH_01_LG") then
        return 3
    elseif model == GetHashKey("A_C_FISHLAKESTURGEON_01_LG") then
        return 4
    elseif model == GetHashKey("A_C_FISHLARGEMOUTHBASS_01_MS") or model == GetHashKey("A_C_FISHLARGEMOUTHBASS_01_LG") then
        return 5
    elseif model == GetHashKey("A_C_FISHLONGNOSEGAR_01_LG") then
        return 6
    elseif model == GetHashKey("A_C_FISHMUSKIE_01_LG") then
        return 7
    elseif model == GetHashKey("A_C_FISHNORTHERNPIKE_01_LG") then
        return 8
    elseif model == GetHashKey("A_C_FISHPERCH_01_MS") or model == GetHashKey("A_C_FISHPERCH_01_SM") then
        return 9
    elseif model == GetHashKey("A_C_FISHREDFINPICKEREL_01_MS") or model == GetHashKey("A_C_FISHREDFINPICKEREL_01_SM") then
        return 10
    elseif model == GetHashKey("A_C_FISHROCKBASS_01_MS") or model == GetHashKey("A_C_FISHROCKBASS_01_SM") then
        return 11
    elseif model == GetHashKey("A_C_FISHSMALLMOUTHBASS_01_LG") or model == GetHashKey("A_C_FISHSMALLMOUTHBASS_01_MS") then
        return 12
    elseif model == GetHashKey("A_C_FISHSALMONSOCKEYE_01_MS") or model == GetHashKey("A_C_FISHSALMONSOCKEYE_01_LG") then
        return 13
    elseif model == GetHashKey("A_C_FISHRAINBOWTROUT_01_LG") or model == GetHashKey("A_C_FISHRAINBOWTROUT_01_MS") then
        return 14
    end
end

function MinManWeightFromIndex(index)
    local min = 0.0
    local max = 0.0

    if index == 0 or index == 1 or index == 2 or index == 3 or index == 9 or index == 10 or index == 11 then
        min = 0.5
        max = 2.0
    elseif index == 3 or index == 4 or index == 6 or index == 7 or index == 8 then
        min = 14.0
        max = 20.0
    elseif index == 5 or index == 12 or index == 13 or index == 14 then
        min = 4.0
        max = 6.0
    end

    min = min * 0.25
    max = max * 0.25

    -- w = w + (w * 0.5)

    return min, max
end

function ComputeFishWeight()
    local fishEntity = get('fishEntity')
    local index = ModelToWeightIndex(fishEntity)
    local min, max = MinManWeightFromIndex(index)

    local weight = math.random() * (max - min) + min

    -- implement fishing_core:func_377 ?

    g_fishWeight = weight --* 54.25
end

-- FOR TESTING PURPOSES

Citizen.CreateThread(
    function()
        local ped = PlayerPedId()

        Citizen.InvokeNative(0xB282DC6EBD803C75, ped, GetHashKey('WEAPON_FISHINGROD'), 500, true, 0);
        Citizen.InvokeNative(0x9B0C7FA063E67629, ped, 'P_FINISHDCRAWDLEGENDARY01X', 0, 1)
    end
)

function DrawStructOnScreen()
    for i, struct_property in ipairs(struct) do        
        DrawScreenText(struct_property.name, 0.65, 0.05 + (i * 0.025), 0.4, 0.4, true, 247, 88, 20, 255, false);
        
        if struct_property.value then
            DrawScreenText(struct_property.value .. '', 0.75, 0.05 + (i * 0.025), 0.4, 0.4, true, 247, 88, 20, 255, false);
        end
    end
end

function _TestVerticalProbeAgainstAllWater(position)
    local _view = DataView.ArrayBuffer(4)
    local retval = Citizen.InvokeNative(0x2B3451FA1E3142E2, position, 1, _view:Buffer(), Citizen.ReturnResultAnyway())
    --TestVerticalProbeAgainstAllWater
    local height = _view:GetFloat32(0)

    return retval, height
end