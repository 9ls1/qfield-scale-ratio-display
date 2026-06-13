import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property bool scaleBoxVisible: true

  // Horisontal og vertikal luft inne i målestokkboksen
  property int boxPaddingX: 5
  property int boxPaddingY: 2

  // Prøver å avgjøre om vi er i en aktiv prosjekt-/kartvisning.
  // Dette er mer robust enn å tegne UI direkte ved plugin-load.
  function hasActiveProjectView() {
    try {
      var mw = iface.mainWindow()
      var canvas = iface.mapCanvas()
      return mw !== null && mw.contentItem !== null && canvas !== null && canvas.mapSettings !== null
    } catch (e) {
      return false
    }
  }

  // Henter gjeldende målestokk fra kartet
  function currentScale() {
    try {
      return iface.mapCanvas().mapSettings.scale
    } catch (e) {
      return 0
    }
  }

  // 9876 -> "9876"
  // 10000 -> "10 000"
  function formatScaleNumber(value) {
    var rounded = Math.round(value)
    if (rounded >= 10000) {
      return rounded.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
    }
    return rounded.toString()
  }

  // Fjerner mellomrom ved innlesing av tekstfeltet
  function unformatScaleNumber(text) {
    return text.replace(/\s/g, "")
  }

  // Setter ønsket målestokk
  function applyScale() {
    var rawText = unformatScaleNumber(scaleField.text)

    if (rawText === "" || rawText === "0")
      return

    var newScale = parseFloat(rawText)
    if (isNaN(newScale) || newScale <= 0) {
      iface.mainWindow().displayToast("Ugyldig målestokk")
      return
    }

    try {
      var canvas = iface.mapCanvas()
      var extent = canvas.mapSettings.extent
      var center = extent.center
      canvas.mapCanvasWrapper.zoomScale(center, newScale, false)
      scaleField.text = formatScaleNumber(newScale)
      scaleField.focus = false
    } catch (e) {
      console.log("zoomScale failed: " + e)
      iface.mainWindow().displayToast("Kunne ikke sette målestokk")
    }
  }

  // Loader sørger for at overlay kun opprettes når kartvisning finnes.
  Loader {
    id: overlayLoader
    active: plugin.hasActiveProjectView()
    sourceComponent: overlayComponent
  }

  Component {
    id: overlayComponent

    Item {
      id: overlayRoot
      parent: plugin.mainWindow ? plugin.mainWindow.contentItem : null

      Rectangle {
        id: scaleBackground
        visible: plugin.scaleBoxVisible

        anchors {
          top: parent.top
          topMargin: 10
          horizontalCenter: parent.horizontalCenter
        }

        width: scaleRow.width + (plugin.boxPaddingX * 2)
        height: scaleRow.height + (plugin.boxPaddingY * 2)

        color: Theme.white
        opacity: 0.6
        radius: 4

        border {
          color: Theme.mainColor
          width: 1
        }

        Row {
          id: scaleRow
          anchors.centerIn: parent
          spacing: 2

          Text {
            id: scalePrefix
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 18
            font.bold: true
            color: Theme.textColor
            text: "1 :"
          }

          TextField {
            id: scaleField
            anchors.verticalCenter: parent.verticalCenter

            width: Math.max(36, contentWidth + 4)
            height: 24

            font.pixelSize: 18
            font.bold: true
            color: Theme.textColor
            text: plugin.formatScaleNumber(plugin.currentScale())

            inputMethodHints: Qt.ImhDigitsOnly
            selectByMouse: true
            horizontalAlignment: TextInput.AlignRight

            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0

            background: Rectangle {
              color: "transparent"
              border.width: 0
            }

            onActiveFocusChanged: {
              if (activeFocus) {
                scaleField.text = Math.round(plugin.currentScale()).toString()
                scaleField.selectAll()
              } else {
                plugin.applyScale()
              }
            }

            onAccepted: plugin.applyScale()
          }
        }

        Connections {
          target: iface.mapCanvas() ? iface.mapCanvas().mapSettings : null

          function onExtentChanged() {
            if (!scaleField.activeFocus) {
              scaleField.text = plugin.formatScaleNumber(plugin.currentScale())
            }
          }
        }
      }

      Rectangle {
        id: toggleButton

        anchors {
          top: parent.top
          topMargin: 10
          right: parent.right
          rightMargin: 65
        }

        width: 42
        height: scaleBackground.height

        color: Theme.white
        opacity: 0.6
        radius: 4

        border {
          color: Theme.mainColor
          width: 1
        }

        Text {
          anchors.centerIn: parent
          text: "1:n"
          font.pixelSize: 16
          font.bold: true
          color: plugin.scaleBoxVisible ? "black" : "gray"
        }

        Rectangle {
          visible: !plugin.scaleBoxVisible
          anchors.centerIn: parent
          width: 24
          height: 2
          color: "gray"
          rotation: -30
          antialiasing: true
        }

        MouseArea {
          anchors.fill: parent
          onClicked: plugin.scaleBoxVisible = !plugin.scaleBoxVisible
        }
      }
    }
  }
}
