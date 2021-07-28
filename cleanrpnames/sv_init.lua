-- Ensure we have the required table and runs the cleanup of roleplay names once DarkRP's database is initialized
local function initCleanRPNames()
  MySQLite.query([[
    CREATE TABLE IF NOT EXISTS darkrp_player_joins(
      sid BIGINT NOT NULL PRIMARY KEY,
      last_joined DATETIME,
      first_checked DATETIME
    );
  ]])
  hook.Run("CleanRoleplayNames")
end
hook.Add("DarkRPDBInitialized", "cleanRoleplayNames:init", initCleanRPNames)
