import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Theme"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 36
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                implicitWidth: 700
                implicitHeight: bar.implicitHeight
                bottomLeftRadius: 8
                bottomRightRadius: 8

                color: Qt.alpha(Theme.colors.background, 0.85)

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    WorkspacesWidget {
                        Layout.leftMargin: 16
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ClockWidget {
                        Layout.rightMargin: 16
                    }
                }
            }
        }
    }
}
