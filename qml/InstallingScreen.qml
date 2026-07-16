import QtQuick
import QtQuick.Controls as QQC2

Item {
    id: root
    property var selectedTags: []
    property real progressRatio: 0

    // ── Header ──
    Column {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 36
        anchors.rightMargin: 36
        anchors.topMargin: 36
        spacing: 6

        Text {
            text: "UMAOS"
            font.family: Theme.sansFont
            font.pixelSize: 13
            font.weight: Font.Medium
            font.letterSpacing: 0.8
            color: Theme.primaryGreen
        }
        Text {
            text: "Installing..."
            font.family: Theme.sansFont
            font.pixelSize: 28
            font.weight: Font.Bold
            font.letterSpacing: -0.3
            color: Theme.textPrimary
        }
        Text {
            id: subtitleText
            text: "Setting up your development environment."
            font.family: Theme.sansFont
            font.pixelSize: 14
            color: Theme.textMuted
        }
    }

    // ── Progress section ──
    Column {
        id: progressSection
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 36
        anchors.rightMargin: 36
        anchors.topMargin: 32
        spacing: 10

        Row {
            width: parent.width
            Text {
                id: currentPkgLabel
                text: "Preparing..."
                font.family: Theme.monoFont
                font.pixelSize: 13
                font.weight: Font.Medium
                color: Theme.textPrimary
                width: parent.width - counterLabel.width
                elide: Text.ElideRight
            }
            Text {
                id: counterLabel
                text: ""
                font.family: Theme.sansFont
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Theme.primaryGreen
                horizontalAlignment: Text.AlignRight
            }
        }

        // Progress bar
        Rectangle {
            id: progressTrack
            width: parent.width
            height: 6
            radius: 3
            color: Theme.divider

            Rectangle {
                id: progressFill
                height: parent.height
                radius: 3
                color: Theme.primaryGreen
                // Bound (not assigned) so it survives window resizes.
                width: progressTrack.width * root.progressRatio

                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // ── Completed list ──
    Column {
        id: completedSection
        anchors.top: progressSection.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 36
        anchors.rightMargin: 36
        anchors.topMargin: 28
        spacing: 8

        Text {
            text: "COMPLETED"
            font.family: Theme.sansFont
            font.pixelSize: 11
            font.weight: Font.Medium
            font.letterSpacing: 0.5
            color: Theme.dimGreen
            visible: completedList.count > 0
        }

        ListView {
            id: completedList
            width: parent.width
            height: contentHeight
            interactive: false
            model: ListModel { id: completedModel }
            spacing: 6

            delegate: Row {
                spacing: 10
                // Green circle check
                Canvas {
                    width: 14
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.fillStyle = Theme.primaryGreen
                        ctx.beginPath()
                        ctx.arc(7, 7, 7, 0, 2 * Math.PI)
                        ctx.fill()
                        ctx.strokeStyle = Theme.nearBlack
                        ctx.lineWidth = 1.5
                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"
                        ctx.beginPath()
                        ctx.moveTo(4, 7)
                        ctx.lineTo(6.2, 9.2)
                        ctx.lineTo(10, 5)
                        ctx.stroke()
                    }
                }
                Text {
                    text: model.name
                    font.family: Theme.monoFont
                    font.pixelSize: 13
                    color: Theme.textMuted
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // ── Error display ──
    // On failure the user was previously stranded here: the message appeared
    // but there was no retry/back/close control anywhere on the screen, so the
    // only way out was killing the window.
    Column {
        id: errorArea
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 36
        spacing: 14
        visible: false

        Text {
            id: errorLabel
            width: parent.width
            text: ""
            font.family: Theme.sansFont
            font.pixelSize: 13
            color: "#ff7c8a"
            wrapMode: Text.WordWrap
        }

        Row {
            spacing: 12

            QQC2.Button {
                text: "Back"
                onClicked: stackView.pop()
            }

            QQC2.Button {
                text: "Retry"
                onClicked: {
                    errorArea.visible = false
                    completedModel.clear()
                    root.progressRatio = 0
                    counterLabel.text = ""
                    currentPkgLabel.text = "Preparing..."
                    backend.install(root.selectedTags)
                }
            }
        }
    }

    // ── Backend connections ──
    Connections {
        target: backend

        function onProgressChanged(current, total) {
            // Store the ratio and let the width bind to it: assigning width
            // imperatively broke the binding, so resizing the window mid-install
            // left the bar at a stale width until the next signal.
            root.progressRatio = total > 0 ? (current / total) : 0
            counterLabel.text = current + " / " + total
        }

        function onCurrentPackageChanged(pkg) {
            currentPkgLabel.text = "Installing " + pkg + "..."
        }

        function onPackageCompleted(pkg) {
            completedModel.append({"name": pkg})
        }

        function onInstallComplete(summary, warning) {
            stackView.push(completeScreen, {"summary": summary, "warning": warning})
        }

        function onInstallError(error) {
            errorLabel.text = error
            errorArea.visible = true
            currentPkgLabel.text = "Installation failed"
        }
    }

    Component.onCompleted: {
        backend.install(selectedTags)
    }
}
