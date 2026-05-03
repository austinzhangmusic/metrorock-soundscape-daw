-- Toggle bypass on the first ReaEQ FX on the master bus.

local FX_NAME_MATCH = "ReaEQ"

local master = reaper.GetMasterTrack(0)
local fx_count = reaper.TrackFX_GetCount(master)
for i = 0, fx_count - 1 do
    local _, name = reaper.TrackFX_GetFXName(master, i, "")
    if name:find(FX_NAME_MATCH, 1, true) then
        local enabled = reaper.TrackFX_GetEnabled(master, i)
        reaper.TrackFX_SetEnabled(master, i, not enabled)
        return
    end
end
