pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var activePlayer: root.players.find(player => {
        return player.isPlaying;
    }) || root.players.find(player => {
        return player.trackTitle.length > 0;
    }) || root.players[0] || null
}
