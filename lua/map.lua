local function GetPosX(pos_x, img_w, scale)
    return tonumber(math.ceil((math.abs(pos_x + img_w))/scale));
end

local function GetPosY(pos_y, img_h, scale)
    return tonumber(math.ceil((math.abs(pos_y + img_h))/scale));
end

local function ToBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

--###########################################################

local menuRef = gui.Reference("Misc");
local menuTab = gui.Tab(menuRef, "Online Radar", "Online Radar");
local menuMainBox = gui.Groupbox(menuTab, "Online Radar", 16, 16, 200, 0);
local menuDelay = gui.Slider(menuMainBox, "online_radar", "Radar Delay", 1, 0.01, 10, 0.01);

local url = "http://16.170.251.81";
local password = "4422";

local dataMain = nil;
local mapName = nil;
local maps = {
    ["cs_agency"]   = {-2947,2492,5.0},
    ["cs_office"]   = {-1838,1858,4.1},
    ["de_ancient"]  = {-2953,2164,5.0},
    ["de_anubis"]   = {-2796,3328,5.22},
    ["de_breach"]   = {-2950,2886,5.5},
    ["de_cache"]    = {-2000,3250,5.5},
    ["de_dust2"]    = {-2476,3239,4.4},
    ["de_inferno"]  = {-2087,3870,4.9},
    ["de_mirage"]   = {-3230,1713,5.0},
    ["de_nuke"]     = {-3453,2887,7.0},
    ["de_overpass"] = {-4831,1781,5.2},
    ["de_train"]    = {-2477,2392,4.7},
    ["de_tuscan"]   = {-5141,1088,4.85},
    ["de_vertigo"]  = {-3168,1762,4.0},
    ["de_shortnuke"]= {-3453,2887,7},
    ["de_shortdust"]= {-2318,2337,3.6},
    ["de_lake"]     = {1200,-700,5.2}
}

local function vector_transform(src, ang, d)
    local newPos = {x =nil; y =nil; z =nil;};

    newPos.x = src.x + (math.cos(math.rad(ang.y)) * d);
    newPos.y = src.y + (math.sin(math.rad(ang.y)) * d);
    newPos.z = src.z + -(math.tan(math.rad(ang.x)) * d);
    return Vector3(newPos.x, newPos.y, newPos.z);
end

local players, player, playerXPos, playerYPos, weapons, weapon, bombXPos, bombYPos, planted, bombPlanted, headPos, eyeAngles, vecForward, trace, traceX, traceY;

local function main()
    if entities.GetLocalPlayer() then
        mapName = engine.GetMapName();

        players = entities.FindByClass("CCSPlayer");
        weapons = entities.FindByClass("CBaseCombatWeapon");
        bombPlanted = entities.FindByClass("CPlantedC4")[1];

        dataMain = '{"local_player": true,"map": "'..mapName..'", "players":[';

        --players
        for i = 1, #players do
            player = players[i];
            playerXPos = tostring(GetPosX(player:GetAbsOrigin().x, maps[mapName][1]*-1, maps[mapName][3]));
            playerYPos = tostring(GetPosY(player:GetAbsOrigin().y, maps[mapName][2]*-1, maps[mapName][3]));

            if player:IsAlive() and player:IsDormant() ~= true then
                dataMain = dataMain .. '{"player_x": "'.. playerXPos .. '", "player_y": "' .. playerYPos ..
                '", "team_num": "' .. player:GetTeamNumber() ..'", "player_name": "'.. player:GetName() ..
                '", "player_health": "'.. player:GetHealth() ..'",';

                headPos = player:GetAbsOrigin() + (player:GetHitboxPosition(0) - player:GetAbsOrigin());
                eyeAngles = player:GetPropVector("m_angEyeAngles");
                eyeAngles.z = 0;
                vecForward = vector_transform(headPos, eyeAngles, 9999);
                trace = engine.TraceLine(headPos, vecForward, 0x400B);

                if trace ~= nil then
                    traceX = tostring(GetPosX(trace.endpos.x, maps[mapName][1]*-1, maps[mapName][3]));
                    traceY = tostring(GetPosY(trace.endpos.y, maps[mapName][2]*-1, maps[mapName][3]));
                    dataMain = dataMain .. '"traceX": "'.. traceX ..'", "traceY": "'.. traceY ..'"},';
                else
                    dataMain = dataMain .. '"traceX": "false", "traceY": "false"},';
                end
            elseif player:IsAlive() == false then
                dataMain = dataMain .. '{"player_dead": "true"},';
            end
        end
        dataMain = dataMain:sub(1, -2) .. ']';

        --bomb dropped
        bombXPos = "false";
        bombYPos = "false";
        planted = "false";
        for i = 1, #weapons do
            weapon = weapons[i];
            if weapon and weapon:GetName() == "weapon_c4" and weapon:GetProp("m_hOwner") == -1 then
                bombXPos = '"'..tostring(GetPosX(weapon:GetAbsOrigin().x, maps[mapName][1]*-1, maps[mapName][3]))..'"';
                bombYPos = '"'..tostring(GetPosY(weapon:GetAbsOrigin().y, maps[mapName][2]*-1, maps[mapName][3]))..'"';
                planted = "false";
            end
        end

        --bomb planted
        if bombPlanted then
            bombXPos = '"'..tostring(GetPosX(bombPlanted:GetAbsOrigin().x, maps[mapName][1]*-1, maps[mapName][3]))..'"';
            bombYPos = '"'..tostring(GetPosY(bombPlanted:GetAbsOrigin().y, maps[mapName][2]*-1, maps[mapName][3]))..'"';
            planted = "true";
        end
        dataMain = dataMain ..',"bomb": {"bomb_x": '..bombXPos..', "bomb_y": '..bombYPos..', "planted":'..planted..'}';
        dataMain = string.gsub(dataMain, "%s+", "")..'}'; --removing spaces from string
    end
end
callbacks.Register("Draw", main);

--send data
local time = common.Time();
local function send_data()
    if common.Time() > time then
        --print(dataMain);
        if entities.GetLocalPlayer() then
            http.Get(url.."/imgdata?data="..ToBase64(dataMain).."&pass="..password, function()end);
        else
            http.Get(url.."/imgdata?data="..ToBase64('{"local_player": false}').."&pass="..password, function()end);
        end
        time = common.Time() + menuDelay:GetValue();
    end
end
callbacks.Register("Draw", send_data);

--send data on Unload
callbacks.Register("Unload", function()
    http.Get(url.."/imgdata?data="..ToBase64('{"local_player": false}').."&pass="..password, function()end);
end);