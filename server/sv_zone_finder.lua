
local WebhookUrl = "https://discord.com/api/webhooks/..."
local MessageId = 1261693964445286420

local ZoneList = {}




Citizen.CreateThread(function()
    Citizen.Wait(Config.ZoneFinder.DelayUponBoot)
	while true do
		Citizen.Wait(Config.ZoneFinder.UpdateInterval)

        -- Wipe the old list
        ZoneList = {}
        
        -- Ping all clients for their zone
        TriggerClientEvent("rainbow_core:PingForZone", -1)

        -- Wait a lil bit for every client to respond
        Citizen.Wait(2 * 1000)

        -- Publish current list to webhook
        UpdateWebhook()
    end
end)

-- Individual returns for the mass ping
RegisterNetEvent("rainbow_core:ReturnPingForZone")
AddEventHandler("rainbow_core:ReturnPingForZone", function(zone)
    if ZoneList[zone] then
        ZoneList[zone] = ZoneList[zone] + 1
    else
        ZoneList[zone] = 1
    end
end)

function UpdateWebhook()

    if GetConvar('discordLogs_dontLog', 'false') == 'true' then
		do return end
	end
	
	if GetConvar('discordLogs_logToDebug', 'false') == 'true' then
		do return end
    end

    -- Build the fields
    local description
    for k,v in pairs(ZoneList) do
        if description then
            description = description .. "\n"
        else
            description = ""
        end
        description = description .. string.format("🗺️᲼᲼**%s:**᲼᲼%d", k, v)
    end

    if not description then
        description = "Looking for freight..."
    end
    description = "᲼᲼\n" .. description .. "\n᲼᲼"

    local botname = "Freight Finder"
    local time = os.date("%m/%d at %I:%M%p")
    local footer = "Last Updated: " .. time .. " UTC"
    local embeds = {
        {
            ["title"] = "Freight Finder",
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = 4777493,
            -- ["fields"] = fieldsList,
            ["footer"]=  {
                ["text"]= footer,
            },
        }
    }
    PerformHttpRequest(WebhookUrl .. "/messages/" .. MessageId, 
    -- PerformHttpRequest(WebhookUrl .. "?wait=true", 
        function(err, text, headers) 
            -- print("err", err)
            -- print("text", text)
            -- print("headers", headers)
        end,
        'PATCH',
        -- 'POST',
        json.encode({ username = botname, embeds = embeds}), 
        { ['Content-Type'] = 'application/json' }
    )
end