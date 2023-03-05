local url = "http://";
local password = "password"; --change it!

local Data = {};
local map_name = nil;
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

local function map()
    Data = {};
    map_name = engine.GetMapName();

    local players = entities.FindByClass("CCSPlayer");

    for i = 1, #players do
        local player = players[i];

        local enemy_x = player:GetAbsOrigin().x;
        local enemy_y = player:GetAbsOrigin().y;
        local x_str = tostring(GetPosX(enemy_x, maps[map_name][1]*-1, maps[map_name][3]));
        local y_str = tostring(GetPosY(enemy_y, maps[map_name][2]*-1, maps[map_name][3]));

        if player:IsAlive() then --and player:IsDormant() == false then
            local info = x_str..":"..y_str..":"..player:GetTeamNumber()..":"..player:GetName();
            table.insert(Data, info);
        end
    end
end
callbacks.Register("Draw", map);

local data_to_send = nil;
local function get_pos()
    if entities.GetLocalPlayer() then
        local data_all;
        for i = 1, #Data do
            data_all = tostring(data_all).."/"..Data[i];
        end
        if data_all ~= nil then
            data_to_send = map_name..data_all:sub(4);
            --draw.Text(500, 500, data_to_send);
        end
    end
end
callbacks.Register("Draw", get_pos);

local curtime = globals.CurTime();
local function send_data()
    if entities.GetLocalPlayer() and data_to_send ~= nil then
        local delay = 0.2;
        if globals.CurTime() > curtime then
            http.Get(url.."/imgdata?data="..ToBase64(data_to_send).."&pass="..password, function()end);
            curtime = globals.CurTime() + delay;
        end
    end
end
callbacks.Register("Draw", send_data);

local function reset_data()
    http.Get(url.."/imgdata?reset=1&pass="..password, function()end);
end
callbacks.Register("Unload", reset_data);

--##########################################

function GetPosX(pos_x, img_w, scale)
    return tonumber(math.ceil((math.abs(pos_x + img_w))/scale));
end

function GetPosY(pos_y, img_h, scale)
    return tonumber(math.ceil((math.abs(pos_y + img_h))/scale));
end

function ToBase64(data)
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