-- Kaitun Main Script
-- Generated at discord.gg/25ms

local KAITUN_SERVICE_NAME = 'jgtoolrobloxrejoin'
local HttpService = game:GetService('HttpService')
local http_request = syn and syn.request or (request or http_request)

local function getHWID()
    local hwid_response = http_request({
        Url = 'https://httpbin.org/headers',
        Method = 'GET',
    })

    if hwid_response and hwid_response.Success then
        local headers = HttpService:JSONDecode(hwid_response.Body).headers

        for header_key, header_value in pairs(headers) do
            if header_key:lower():find('fingerprint') then
                return header_value
            end
        end

        warn('[Bocchi World] Kh\xF4ng t\xECm \u{111}\u{1B0}\u{1EE3}c hwid')
    else
        warn('[Bocchi World] Request th\u{1EA5}t b\u{1EA1}i:', hwid_response and hwid_response.StatusMessage or 'Kh\xF4ng r\xF5 l\u{1ED7}i')
    end

    return nil
end

if (function()
    local hwid = getHWID()
    local auth_request = {
        Url = 'https://pandadevelopment.net/v2_validation?key=' .. getgenv().KeyKaitun .. '&service=' .. KAITUN_SERVICE_NAME .. '&hwid=' .. hwid,
        Method = 'GET',
    }
    local auth_response = http_request(auth_request)

    print('[Kaitun AA - Bocchi World]')
    print('--------')

    if not auth_response.Success then
        print('[Bocchi World] Error: Request failed')
        print('--------')
        print('[Bocchi World] Made by Jung Ganmyeon & Dustn')
        print('--------')

        return false
    end

    local auth_data = HttpService:JSONDecode(auth_response.Body)

    if auth_data.V2_Authentication ~= 'success' then
        print('[Bocchi World] Wrong Key')
    else
        print('[Bocchi World] Check success \u{2705}')
    end

    print('--------')
    print('[Bocchi World] Made by Jung Ganmyeon & Dustn')
    print('--------')

    return auth_data.V2_Authentication == 'success'
end)() then
    print('[Bocchi World] Authentication Successfully!')

    local Players = game:GetService('Players')
    local RunService = game:GetService('RunService')

    game:GetService('TweenService')
    game:GetService('UserInputService')

    local theme = {
        primary = Color3.fromRGB(255, 192, 203),
        secondary = Color3.fromRGB(50, 50, 50),
        background = Color3.fromRGB(0, 0, 0),
        text = Color3.fromRGB(255, 255, 255),
        text_secondary = Color3.fromRGB(200, 200, 200),
        success = Color3.fromRGB(46, 204, 113),
        error = Color3.fromRGB(231, 76, 60),
        loader_overlay = Color3.fromRGB(0, 0, 0),
        border = Color3.fromRGB(100, 100, 100),
    }

    local function formatNumber(value)
        if value >= 1000000 then
            return string.format('%.1fM', value / 1000000)
        elseif value >= 1000 then
            return string.format('%.1fK', value / 1000)
        else
            return tostring(value)
        end
    end

    local function createStatRow(parent, stat_name, icon, position)
        local frame = Instance.new('Frame')

        frame.Name = stat_name
        frame.BackgroundColor3 = theme.secondary
        frame.Size = UDim2.new(0.9, 0, 0, 60)
        frame.Position = position
        frame.Parent = parent

        local ui_corner = Instance.new('UICorner')
        ui_corner.CornerRadius = UDim.new(0, 12)
        ui_corner.Parent = frame

        local ui_stroke = Instance.new('UIStroke')
        ui_stroke.Color = theme.border
        ui_stroke.Thickness = 2
        ui_stroke.Parent = frame

        local icon_label = Instance.new('TextLabel')
        icon_label.BackgroundTransparency = 1
        icon_label.Size = UDim2.new(0, 40, 1, -10)
        icon_label.Position = UDim2.new(0, 10, 0, 5)
        icon_label.Font = Enum.Font.GothamBold
        icon_label.Text = icon
        icon_label.TextColor3 = theme.text
        icon_label.TextSize = 20
        icon_label.Parent = frame

        local name_label = Instance.new('TextLabel')
        name_label.BackgroundTransparency = 1
        name_label.Size = UDim2.new(0, 150, 0, 20)
        name_label.Position = UDim2.new(0, 60, 0, 5)
        name_label.Font = Enum.Font.GothamMedium
        name_label.Text = stat_name
        name_label.TextColor3 = theme.text_secondary
        name_label.TextSize = 14
        name_label.TextXAlignment = Enum.TextXAlignment.Left
        name_label.Parent = frame

        local value_label = Instance.new('TextLabel')
        value_label.BackgroundTransparency = 1
        value_label.Size = UDim2.new(1, -70, 0, 20)
        value_label.Position = UDim2.new(0, 60, 0, 30)
        value_label.Font = Enum.Font.GothamSemibold
        value_label.Text = '0'
        value_label.TextColor3 = theme.text
        value_label.TextSize = 16
        value_label.TextXAlignment = Enum.TextXAlignment.Left
        value_label.Parent = frame

        return value_label
    end

    (function()
        local screen_gui = Instance.new('ScreenGui')
        screen_gui.Name = 'BocchiWorldUI'
        screen_gui.ResetOnSpawn = false
        screen_gui.IgnoreGuiInset = true
        screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screen_gui.Parent = Players.LocalPlayer:WaitForChild('PlayerGui')

        local main_frame = Instance.new('Frame')
        main_frame.Name = 'MainContainer'
        main_frame.BackgroundColor3 = theme.background
        main_frame.BorderSizePixel = 0
        main_frame.Size = UDim2.new(1, 0, 1, 0)
        main_frame.Position = UDim2.new(0, 0, 0, 0)
        main_frame.Parent = screen_gui

        local title_label = Instance.new('TextLabel')
        title_label.Name = 'Title'
        title_label.BackgroundTransparency = 1
        title_label.Size = UDim2.new(1, 0, 0, 50)
        title_label.Position = UDim2.new(0, 0, 0, 10)
        title_label.Font = Enum.Font.GothamBlack
        title_label.Text = 'Bocchi World Kaitun Stats'
        title_label.TextColor3 = theme.text
        title_label.TextSize = 24
        title_label.TextXAlignment = Enum.TextXAlignment.Center
        title_label.Parent = main_frame

        local stats_container = Instance.new('Frame')
        stats_container.Name = 'StatsContainer'
        stats_container.BackgroundTransparency = 1
        stats_container.Size = UDim2.new(0.9, 0, 0.8, 0)
        stats_container.Position = UDim2.new(0.05, 0, 0.1, 0)
        stats_container.Parent = main_frame

        local list_layout = Instance.new('UIListLayout')
        list_layout.Padding = UDim.new(0, 10)
        list_layout.Parent = stats_container

        local stats_ui = {
            waves = createStatRow(stats_container, 'Waves', '\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}', UDim2.new(0, 0, 0, 0)),
            candy = createStatRow(stats_container, 'Candy', '\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}', UDim2.new(0, 0, 0, 70)),
            gold = createStatRow(stats_container, 'Gold', '\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}', UDim2.new(0, 0, 0, 140)),
            legacy = createStatRow(stats_container, 'Legacy', '\u{2B50}', UDim2.new(0, 0, 0, 210)),
            stars = createStatRow(stats_container, 'Stars', '\u{2728}', UDim2.new(0, 0, 0, 280)),
            gems = createStatRow(stats_container, 'Gems', '\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}\u{FFFD}', UDim2.new(0, 0, 0, 350)),
        }

        RunService.RenderStepped:Connect(function()
            local player_stats = Players.LocalPlayer:FindFirstChild('_stats')

            if player_stats then
                stats_ui.waves.Text = formatNumber(player_stats:FindFirstChild('_wave_num') and (player_stats.waves.Value or 0) or 0)
                stats_ui.candy.Text = formatNumber(player_stats:FindFirstChild('_resourceCandies') and (player_stats._resourceCandies.Value or 0) or 0)
                stats_ui.gold.Text = formatNumber(player_stats:FindFirstChild('gold_amount') and (player_stats.gold_amount.Value or 0) or 0)
                stats_ui.legacy.Text = formatNumber(player_stats:FindFirstChild('_resourceGemsLegacy') and (player_stats._resourceGemsLegacy.Value or 0) or 0)
                stats_ui.stars.Text = formatNumber(player_stats:FindFirstChild('_resourceHolidayStars') and (player_stats._resourceHolidayStars.Value or 0) or 0)
                stats_ui.gems.Text = formatNumber(player_stats:FindFirstChild('gem_amount') and player_stats.gem_amount.Value or 0)
            end
        end)
    end)()

    local get_all_units = function()
        local workspace_children = game:GetService('Workspace'):GetChildren()
        local units_list = {}

        for _, child in ipairs(workspace_children) do
            if child:IsA('Model') and child:FindFirstChild('_stats') then
                local unit_stats = child._stats
                local unit_id = unit_stats:FindFirstChild('unit_id')
                local uuid = unit_stats:FindFirstChild('uuid')

                if unit_id and uuid then
                    table.insert(units_list, {
                        name = child.Name,
                        unit_id = unit_id.Value,
                        uuid = uuid.Value,
                        stats = unit_stats,
                    })
                end
            end
        end

        return units_list
    end

    local get_owned_units = function()
        local success, result = pcall(function()
            return game:GetService('ReplicatedStorage'):WaitForChild('units', 5)
        end)

        if not success then
            return {}
        end

        return result[1]:GetChildren()
    end

    local get_inventory_items = function()
        return {}
    end

    local return_to_lobby = function()
        pcall(function()
            game:GetService('ReplicatedStorage').endpoints.client_to_server.teleport_back_to_lobby:InvokeServer()
        end)
    end

    local get_start_position = function()
        return Vector3.new(20, 20, 20)
    end

    local preload_unit_data = function()
        pcall(function()
            game:GetService('ReplicatedStorage').endpoints.client_to_server.get_unit_data:InvokeServer()
        end)
    end

    local place_unit = function(unit_uuid, position)
        pcall(function()
            game:GetService('ReplicatedStorage').endpoints.client_to_server.place_unit_ingame:InvokeServer(unit_uuid, position)
        end)
    end

    local buy_unit = function(unit_id)
        pcall(function()
            game:GetService('ReplicatedStorage').endpoints.client_to_server.buy_unit_ingame:InvokeServer(unit_id)
        end)
    end

    local upgrade_units = function()
        local all_units = get_all_units()

        for _, unit in ipairs(all_units) do
            for upgrade_count = 1, 3 do
                pcall(function()
                    game:GetService('ReplicatedStorage').endpoints.client_to_server.upgrade_unit_ingame:InvokeServer(unit)
                end)
                wait(1.5)
            end
        end

        print('\u{110}\u{E3} upgrade xong t\u{1EA5}c \u{1EA3} unit!')
    end

    local check_gem = function()
        local player = Players.LocalPlayer:FindFirstChild('stats')

        if player then
            local gem_amount = player:FindFirstChild('gem_amount')

            if gem_amount then
                return gem_amount.Value
            end
        end

        return 0
    end

    local check_gem_evo = function()
        return check_gem() >= (getgenv().EvoGem or 1000)
    end

    local autosell = function()
        while true do
            wait(getgenv().SellDelay or 1)

            pcall(function()
                game:GetService('ReplicatedStorage').endpoints.client_to_server.sell_all_units:InvokeServer()
            end)
            print('\u{110}\u{E3} sell xong!')
        end
    end

    local auto_setting = function()
        print('Auto Setting \u{111}\u{E3} b\u{1EAD}t \u{111}\u{1EA7}u!')
    end

    local check_return_or_replay = function()
        if check_gem_evo() then
            print('\u{110}\u{E3} \u{111}\u{1EE7} gem \u{111}\u{1EC3} evolution!')

            return true
        end

        return false
    end

    function super_kaitun_1()
        preload_unit_data()

        local owned_units = get_owned_units()
        local start_pos = get_start_position()
        local placed_positions = {}
        local placement_index = 0

        for _, unit in ipairs(owned_units) do
            local unit_id = unit:FindFirstChild('unit_id')
            local uuid = unit:FindFirstChild('uuid')
            local cost = unit:FindFirstChild('cost')

            if unit_id and uuid and cost then
                local cost_value = cost.Value or 0

                if check_gem() >= cost_value then
                    local unit_uuid = uuid.Value
                    local spawn_cap = unit:FindFirstChild('spawn_cap')
                    local max_spawn = spawn_cap and spawn_cap.Value or 1

                    for spawn_index = 1, max_spawn do
                        local position = start_pos + Vector3.new(placement_index % 7 * 3, 0, math.floor(placement_index / 7) * 3)

                        place_unit(unit_uuid, position)
                        table.insert(placed_positions, position)
                        placement_index = placement_index + 1
                        print('\u{110}\u{E3} \u{111}\u{1EB7}t unit:', unit_id.Value, '\u{1EDF}i v\u{1ECB} tr\u{ED}:', position)
                        wait(2)
                    end
                end
            end
        end

        upgrade_units()
        wait(3)
        game:GetService('ReplicatedStorage').endpoints.client_to_server.vote_start:InvokeServer()
        print('\u{110}\u{E3} start game!')
    end

    function sell_all_unit_on_wave()
        while true do
            wait(1)

            local workspace_children = game:GetService('Workspace'):GetChildren()
            local has_units = false

            for _, child in ipairs(workspace_children) do
                if child:IsA('Model') and child:FindFirstChild('_stats') then
                    has_units = true

                    break
                end
            end

            if not has_units then
                break
            end

            local units = get_all_units()
            local sold_any = false

            for _, unit in ipairs(units) do
                local unit_uuid = unit.stats:FindFirstChild('uuid')

                if unit_uuid then
                    local uuid_value = unit_uuid.Value
                    local owned = get_owned_units()
                    local is_owned = false

                    for _, owned_unit in ipairs(owned) do
                        local owned_uuid = owned_unit:FindFirstChild('uuid')

                        if owned_uuid and owned_uuid.Value == uuid_value then
                            is_owned = true

                            break
                        end
                    end

                    if is_owned then
                        game:GetService('ReplicatedStorage').endpoints.client_to_server.sell_unit_ingame:InvokeServer(unpack({unit}))
                        print('\u{110}\u{E3} b\xE1n unit:', unit.name)

                        sold_any = true
                    end
                end
            end

            if not sold_any then
                break
            end

            wait(1)
        end

        print('Kh\xF4ng c\xF2n unit n\xE0o \u{111}\u{1EC3} b\xE1n.')
    end

    function logic_place_upg_sell()
        local owned_units = get_owned_units()

        preload_unit_data()

        local unit_keys = {}
        local placement_count = 0
        local unit_index = 1

        for unit_key, _ in pairs(owned_units) do
            table.insert(unit_keys, tonumber(unit_key))
        end

        table.sort(unit_keys)

        local start_pos = get_start_position()

        while placement_count < (getgenv().MaxPlacement or 50) and unit_index <= #unit_keys do
            local unit_id_str = tostring(unit_keys[unit_index])
            local unit_data = owned_units[unit_id_str]
            local cost = unit_data.cost or 0
            local spawn_cap = unit_data.spawn_cap or 0
            local spawn_count = 0

            while spawn_count < spawn_cap do
                buy_unit(cost)

                local position = start_pos + Vector3.new(placement_count % 7 * 3, 0, math.floor(placement_count / 7) * 3)

                place_unit(unit_data.uuid, position)
                table.insert(unit_keys, position)

                placement_count = placement_count + 1
                spawn_count = spawn_count + 1

                print('\u{110}\u{E3} \u{111}\u{1EB7}t unit:', unit_id_str, 'T\u{1EA1}i v\u{1ECB} tr\u{ED}:', position)
                wait(2)
            end

            unit_index = unit_index + 1
        end

        upgrade_units()
        sell_all_unit_on_wave()
    end

    function check_starfruit_quantities(unit_id)
        local requirements = unit_requirements[unit_id]

        if not requirements then
            warn('No StarFruit configuration found for unit: ' .. unit_id)

            return false
        end

        local inventory = get_inventory_items()

        for item_name, required_amount in pairs(requirements) do
            local available_amount = inventory[item_name] or 0

            if available_amount < required_amount then
                warn(string.format('Not enough %s for unit: %s (Required: %d, Available: %d)', item_name, unit_id, required_amount, available_amount))

                return false
            end
        end

        return true
    end

    function check_unit_takedowns(unit_uuid, required_takedowns)
        local owned_units = get_owned_units()

        for _, unit in pairs(owned_units) do
            if unit.uuid == unit_uuid and unit.total_takedowns then
                if required_takedowns <= unit.total_takedowns then
                    return true
                end

                warn(string.format('Unit %s does not have enough takedowns (Required: %d, Current: %d)', unit.unit_id, required_takedowns, unit.total_takedowns))

                return false
            end
        end

        warn('Unit not found or does not have takedown data: ' .. unit_uuid)

        return false
    end

    function auto_evo_units()
        local owned_units = get_owned_units()
        local evo_config = getgenv().UnitEvo
        local required_takedowns = 10000

        for unit_id, should_evo in pairs(evo_config) do
            if should_evo then
                local target_unit = nil

                for _, unit in pairs(owned_units) do
                    if unit.unit_id == unit_id then
                        target_unit = unit

                        break
                    end
                end

                if target_unit then
                    local has_starfruit = check_starfruit_quantities(unit_id)
                    local has_takedowns = check_unit_takedowns(target_unit.uuid, required_takedowns)

                    if has_starfruit then
                        if has_takedowns then
                            local evo_params = {
                                target_unit.uuid,
                            }

                            game:GetService('ReplicatedStorage').endpoints.client_to_server.evolve_unit:InvokeServer(unpack(evo_params))
                            print('Unit evolved successfully: ' .. unit_id)
                        else
                            warn('Unit does not have enough takedowns to evolve: ' .. unit_id)
                        end
                    else
                        warn('Not enough StarFruit to evolve the unit: ' .. unit_id)
                    end
                else
                    warn('Target unit not found: ' .. unit_id)
                end
            else
                print('Skipping unit: ' .. unit_id .. ' (Evo not enabled)')
            end
        end
    end

    function check_lobby_1()
        if check_gem() >= getgenv().Gem then
            print('S\u{1ED1} gem \u{111}\u{E3} \u{111}\u{1EE7} b\u{1EAF}t \u{111}\u{1EA7}u change acc.')
            return_to_lobby()
        else
            print('S\u{1ED1} gem kh\xF4ng \u{111}\u{1EE7}')
            autosell()
            super_kaitun_1()
        end
    end

    function check_namek()
        if check_gem() >= getgenv().Gem then
            print('Gem \u{111}\u{E3} \u{111}\u{1EE7}, tr\u{1EDF} v\u{1EC1} lobby')
            game:GetService('ReplicatedStorage').endpoints.client_to_server.teleport_back_to_lobby:InvokeServer()
        else
            print('Gem ch\u{1B0}a \u{111}\u{1EE7}, farm gem ti\u{1EBF}p')
            game:GetService('ReplicatedStorage').endpoints.client_to_server.vote_start:InvokeServer()
            print('start game')
            wait(2)
            logic_place_upg_sell()
            auto_setting()
            check_return_or_replay()
        end
    end

    if game.PlaceId ~= 8304191830 then
        check_namek()
        print('\u{110}ang trong map, b\u{1EAF}t \u{111}\u{1EA7}u kaitun.')
    else
        print('\u{110}ang trong lobby, b\u{1EAF}t \u{111}\u{1EA7}u kaitun')
        autosell()
        check_lobby_1()
    end
else
    print('[Bocchi World] Authentication Failed!')
end
