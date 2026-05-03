-- Smoothly fades track 4 between 0 dB and silence over 2 seconds.
-- Re-invoking mid-fade reverses direction immediately.
-- Lerps in linear amplitude space so the fade-in is audible from the start.

local TRACK_IDX = 3
local FADE_TIME = 2.0
local TOP_DB = 0.0
local BOTTOM_DB = -150.0
local STATE_NS = "Metrorock"
local STATE_KEY = "fade_gen_" .. TRACK_IDX

local function db_to_linear(db)
    if db <= -149 then return 0 end
    return 10 ^ (db / 20)
end

local function linear_to_db(lin)
    if lin <= 1e-8 then return -150 end
    return 20 * math.log(lin, 10)
end

local track = reaper.GetTrack(0, TRACK_IDX)
if not track then return end

reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)

local cur_amp = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
local cur_db = linear_to_db(cur_amp)
local target_db = (cur_db > (TOP_DB + BOTTOM_DB) / 2) and BOTTOM_DB or TOP_DB
local target_amp = db_to_linear(target_db)

local start_time = reaper.time_precise()
local start_amp = cur_amp

local my_gen = (tonumber(reaper.GetExtState(STATE_NS, STATE_KEY)) or 0) + 1
reaper.SetExtState(STATE_NS, STATE_KEY, tostring(my_gen), false)

local function tick()
    if (tonumber(reaper.GetExtState(STATE_NS, STATE_KEY)) or 0) ~= my_gen then return end
    local now = reaper.time_precise()
    local t = (now - start_time) / FADE_TIME
    if t >= 1 then
        reaper.SetMediaTrackInfo_Value(track, "D_VOL", target_amp)
        return
    end
    local cur_amp_now = start_amp + (target_amp - start_amp) * t
    reaper.SetMediaTrackInfo_Value(track, "D_VOL", cur_amp_now)
    reaper.defer(tick)
end

reaper.defer(tick)
