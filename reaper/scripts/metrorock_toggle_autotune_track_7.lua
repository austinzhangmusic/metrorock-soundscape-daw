-- Toggle bypass on the first Graillon FX on track 7 (mic channel).

local TRACK_IDX = 6  -- 0-based, so track 7
local FX_NAME_MATCH = "Graillon"

local track = reaper.GetTrack(0, TRACK_IDX)
if not track then return end

local fx_count = reaper.TrackFX_GetCount(track)
for i = 0, fx_count - 1 do
    local _, name = reaper.TrackFX_GetFXName(track, i, "")
    if name:find(FX_NAME_MATCH, 1, true) then
        local enabled = reaper.TrackFX_GetEnabled(track, i)
        reaper.TrackFX_SetEnabled(track, i, not enabled)
        return
    end
end
