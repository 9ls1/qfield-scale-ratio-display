import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property bool scaleBoxVisible: true
  property bool projectUiVisible: false

  property int boxPaddingX: 5
  property int boxPaddingY: 2

  function hasOpenProject() {
    try {
      var canvas = iface.mapCanvas()
      if (!canvas || !canvas.mapSettings)
        return false

      // QField 4.2.2: canvas kan eksistere også uten prosjekt.
      // Vi prøver derfor å sjekke om extent ser gyldig ut og om wrapper finnes.
      var wrapper = canvas.mapCanvasWrapper
      var extent = canvas.mapSettings.extent

      if (!wrapper || !extent)
        return false

      // Hvis extent er null/ubrukelig i menyer, vil dette ofte sile dem bort.
      if (extent.width <= 0 || extent.height <= 0)
        return false

      return true
    } catch (e) {
      return false
    }
  }

  function refreshVisibility() {
    projectUiVisible = hasOpenProject()
  }

  function currentScale() {
    try {
      return iface.mapCanvas().mapSettings.scale
    } catch (e) {
      return 0
    }
  }

  function formatScaleNumber(value) {
    var rounded = Math.round(value)
    if (rounded >= 10000) {
      return rounded.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
    }
    return rounded.toString()
  }

  function unformatScaleNumber(text) {
    return text.replace(/\s/g, "")
  }

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

  Timer {
    id: visibilityTimer
    interval: 500
    repeat: true
    running: true
    onTriggered: plugin.refreshVisibility()
  }

  Component.onCompleted: refreshVisibility()

  Item {
    id: overlayRoot
    parent: plugin.mainWindow ? plugin.mainWindow.contentItem : null
    anchors.fill: parent
    visible: plugin.projectUiVisible

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
          if (!scaleField.activeFocus && plugin.projectUiVisible) {
            scaleField.text = plugin.formatScaleNumber(plugin.currentScale())
          }
        }
      }
    }

    Rectangle {
      id: toggleButton
      visible: true

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
