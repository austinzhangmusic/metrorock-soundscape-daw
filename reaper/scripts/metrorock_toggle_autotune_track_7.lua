-- Toggle bypass on the first Spoton FX on tracks 7 and 8 (mic channels).
-- Treats the two as a unit: if either is currently enabled, disables both;
-- if both are disabled, enables both. Keeps them in sync regardless of drift.

local TRACK_INDICES = {6, 7}  -- 0-based, so tracks 7 and 8
local FX_NAME_MATCH = "Spoton"

local function find_fx(track, match)
    if not track then return nil end
    local fx_count = reaper.TrackFX_GetCount(track)
    for i = 0, fx_count - 1 do
        local _, name = reaper.TrackFX_GetFXName(track, i, "")
        if name:find(match, 1, true) then
            return i
        end
    end
    return nil
end

local hits = {}
local any_enabled = false
for _, idx in ipairs(TRACK_INDICES) do
    local track = reaper.GetTrack(0, idx)
    local fx_idx = find_fx(track, FX_NAME_MATCH)
    if fx_idx then
        hits[#hits + 1] = {track = track, fx_idx = fx_idx}
        if reaper.TrackFX_GetEnabled(track, fx_idx) then
            any_enabled = true
        end
    end
end

local target = not any_enabled
for _, h in ipairs(hits) do
    reaper.TrackFX_SetEnabled(h.track, h.fx_idx, target)
end
