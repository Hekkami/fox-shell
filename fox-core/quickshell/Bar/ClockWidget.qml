import QtQuick
import "../Theme"

Text {
    color: Theme.colors.bright_foreground
    font.pixelSize: Theme.fontSize
    font.weight: 700
    font.family: Theme.fontFamily

    text: TimeService.time
}
