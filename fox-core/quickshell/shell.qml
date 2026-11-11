import Quickshell
import QtQuick
import Theme

ShellRoot {
    PanelWindow {
        id: bar
        
        anchors {
            top: true
            left: true
            right: true
        }
        
        height: 36
        color: "transparent"
        

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(
              parseInt(Theme.colors.background.substr(1, 2), 16) / 255,
              parseInt(Theme.colors.background.substr(3, 2), 16) / 255,
              parseInt(Theme.colors.background.substr(5, 2), 16) / 255,
              0.85
            )

            Text {
                anchors.centerIn: parent
                text: "Quickshell + Hyprland"
                color: Theme.colors.foreground
                font.pixelSize: 14
            }
        }
    }
}
