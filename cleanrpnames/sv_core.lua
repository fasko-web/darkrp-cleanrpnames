-- Creates/Updates a SteamID64's first_checked time
function DarkRP.createPlayerCheckData(sid)
  MySQLite.query([[REPLACE INTO darkrp_player_joins (sid, first_checked) VALUES(]] ..
    sid .. [[, ]] ..
    os.time() .. ");")
end

-- Gets a steamID64's join data, and creates some placeholders if one doesn't exist
function DarkRP.retrieveSteamID64JoinData(sid, callback)
  MySQLite.query("SELECT last_joined, first_checked FROM darkrp_player_joins WHERE sid = " .. sid .. ";", function(data)
    local info = data and data[1] or {}
    info.last_joined = {info.last_joined or nil}
    info.first_checked = {info.first_checked or os.time()}
    if not data then DarkRP.createPlayerCheckData(sid) end
    if callback then callback(info) end
  end)
end

-- Sets a roleplay name to NULL for a SteamID64
function DarkRP.removePlayerRoleplayName(sid)
  MySQLite.query("UPDATE darkrp_player SET rpname = NULL WHERE uid = " .. sid .. ";")
end

-- Cleans the rpname of users that haven't joined in the last 90 days or whatever is specifed in the config
local function cleanRoleplayNames()
  MySQLite.query("SELECT uid, rpname FROM darkrp_player", function(players)
    local cleanDuration = isnumber(CleanRPName.DurationInDays) and CleanRPName.DurationInDays or 90
    for _, v in pairs(players or {}) do
      DarkRP.retrieveSteamID64JoinData(v.uid, function(data)
        if not data.last_joined and data.first_checked then
          if data.first_checked < os.difftime(os.time, 86400 * cleanDuration) then
            DarkRP.removePlayerRoleplayName(v.uid)
          end
        end
        if data.last_joined then
          if data.last_joined < os.difftime(os.time, 86400 * cleanDuration) then
            DarkRP.removePlayerRoleplayName(v.uid)
          end
        end
      end)
    end
  end)
end
hook.Add("CleanRoleplayNames", "cleanRoleplayNames:run", cleanRoleplayNames)

-- Creates/Updates a player's last_joined time
function DarkRP.createPlayerJoinData(ply)
  MySQLite.query([[REPLACE INTO darkrp_player_joins(sid, last_joined) VALUES(]] .. 
    ply:SteamID64() .. [[, ]] ..
    os.time() .. ");")
end

-- Gets a player's last_joined time, and creates one if it doesn't exist
function DarkRP.retrievePlayerLastJoinData(ply)
  if not IsValid(ply) then return end
  MySQLite.query("SELECT last_joined FROM darkrp_player_joins WHERE sid = " .. ply:SteamID64() .. ";", function(data)
    local last_joined = data and data[1] or os.time()
    ply:setDarkRPVar('last_joined', last_joined)
    if not data then DarkRP.createPlayerJoinData(ply) end
  end)
end

-- Create an entry in darkrp_player_join on the player's first connection to the server
hook.Add("onPlayerFirstJoined", "cleanRolePlayNames:addPlayer", DarkRP.retrievePlayerLastJoinData(ply))

-- Update an entry in darkrp_player_joins for a player upon connecting to the server
local function updatePlayerOnJoin(data)
  if data.bot return end
  local ply = Entity(data.index)
  DarkRP.retrievePlayerLastJoinData(ply)
end
gameevent.Listen( "player_connect_client" )
hook.Add("player_connect_client", "cleanRolePlayNames:updatePlayer", updatePlayerOnJoin(data))
