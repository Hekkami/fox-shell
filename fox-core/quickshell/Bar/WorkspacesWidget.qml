import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../Theme"

RowLayout {
    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            required property var modelData
            implicitHeight: 22
            implicitWidth: modelData.focused ? 60 : 40
            radius: implicitHeight / 2

            color: modelData.focused ? Theme.colors.primary : Theme.colors.secondary
            visible: modelData.id > 0

            Text {
                anchors.centerIn: parent
                text: modelData.id

                color: modelData.focused ? Theme.colors.primary_fg : Theme.colors.secondary_fg
                font.pixelSize: Theme.fontSize
                font.weight: 700
                font.family: Theme.fontFamily
            }
        }
    }
}
