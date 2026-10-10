import QtQuick
import Quickshell.Services.UPower
import qs.features.bar

// Active power profile, glyph only. tuned-ppd maps tuned's profiles onto the
// three power-profiles-daemon modes, so this never sees tuned's own names.
// Display only.
BarItem {
    glyph: PowerProfiles.profile === PowerProfile.Performance ? "speed" : PowerProfiles.profile === PowerProfile.PowerSaver ? "energy_savings_leaf" : "speed_3"
}
