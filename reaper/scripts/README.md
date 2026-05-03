# Metrorock Reaper scripts

ReaScripts triggered by piezo taps via MIDI. The 8 sensors map to:

| Sensor | Note | Action |
|--------|------|--------|
| 0 | 60 | `metrorock_fade_track_1.lua` — fade track 1 |
| 1 | 61 | `metrorock_fade_track_2.lua` — fade track 2 |
| 2 | 62 | `metrorock_fade_track_3.lua` — fade track 3 |
| 3 | 63 | `metrorock_fade_track_4.lua` — fade track 4 |
| 4 | 64 | `metrorock_fade_track_5.lua` — fade track 5 up while ducking track 6 (-10 dB) |
| 5 | 65 | `metrorock_mute_tracks_1_5.lua` — panic mute toggle on tracks 1-5 |
| 6 | 66 | `metrorock_toggle_eq_master.lua` — bypass/enable ReaEQ on master bus |
| 7 | 67 | `metrorock_toggle_autotune_track_7.lua` — bypass/enable Spoton on track 7 |

## Fade scripts (tracks 1-5)

Fade between 0 dB and silence over 2 seconds on each invocation. Direction
is automatic: if the track is currently near the top, the next call fades
it down; if near silence, it fades up. Re-tapping mid-fade cancels the
in-flight fade and reverses immediately.

## Loading into Reaper

For each `metrorock_fade_track_N.lua`:

1. Reaper → Actions → Show action list (or press `?`)
2. Click **ReaScript: Load...** → browse to the `.lua` file → Open
3. The script appears in the action list as `Custom: metrorock_fade_track_N.lua`

## Binding to MIDI

Replace your existing "Track: Toggle mute for track NN" bindings with the
new fade scripts. Otherwise both fire on the same note and you'll mute *and*
fade simultaneously.

For each track:

1. In the action list, find the existing **Track: Toggle mute for track 0N**
2. Select it → at the bottom, click **Delete** under "Shortcuts for selected action"
   (this removes the MIDI binding only, the action itself stays)
3. Find **Custom: metrorock_fade_track_N.lua** → click **Add...** under
   "Shortcuts for selected action"
4. With the dialog focused, fire the corresponding TD pulse so Reaper
   captures the note (60 for track 1, 61 for track 2, …, 64 for track 5)

## Tuning

Edit per file:

- `FADE_TIME` — seconds for a full fade (default 2.0)
- `TOP_DB` — peak volume (default 0.0; can go up to ~+12)
- `BOTTOM_DB` — floor volume (default -150.0, effectively silent)

Lerp is in linear amplitude space (matching how DAW automation typically
interpolates volume), so fade-up is audible from the start of the fade
rather than waiting until the last fraction of a second to enter the
audible range.

## Macro scripts (sensors 5-7)

**`metrorock_mute_tracks_1_5.lua`** — Toggles `B_MUTE` on tracks 1-5. If any
are currently unmuted, mutes all five; if all are muted, unmutes all five.
Operates on the mute flag directly, independent of fader position, so it
works as a panic kill regardless of where the per-track fades have left
each volume. Also force-disables ReaEQ on master and Spoton on track 7
if they're currently enabled — this is one-way (only disables; never
re-enables), so an "un-panic" tap restores the track mutes but leaves the
FX off until you re-enable them via sensors 6 / 7.

**`metrorock_toggle_eq_master.lua`** — Walks the master bus FX chain looking
for the first FX whose name contains `ReaEQ` and toggles its bypass state.
If you have multiple ReaEQ instances, only the first is touched. Substring
match, so `ReaEQ`, `ReaEQ (Cockos)`, and `ReaEQ-Bandsplit` all qualify.

**`metrorock_toggle_autotune_track_7.lua`** — Same pattern, but on track 7
(0-based index 6) looking for the first FX whose name contains `Spoton`.
Adjust `TRACK_IDX` if your mic channel ends up on a different track, or
`FX_NAME_MATCH` if you use a different autotune plugin.

For all three, FX-name matching is case-sensitive and uses Lua's
`string.find` with the plain-text flag, so no regex escaping is needed.
