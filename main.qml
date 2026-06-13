import QtQuick
import QtQuick.Controls

import org.qfield
import Theme

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property bool scaleBoxVisible: false

  property int boxPaddingX: 5
  property int boxPaddingY: 2

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
      mainWindow.displayToast("Ugyldig målestokk")
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
      mainWindow.displayToast("Kunne ikke sette målestokk")
    }
  }

  Component.onCompleted: {
    iface.addItemToPluginsToolbar(pluginButton)
  }

  QfToolButton {
    id: pluginButton
    iconSource: "icon.svg"
    iconColor: Theme.mainColor
    bgcolor: Theme.darkGray
    round: true

    onClicked: {
      plugin.scaleBoxVisible = !plugin.scaleBoxVisible
      if (plugin.scaleBoxVisible) {
        scaleField.text = plugin.formatScaleNumber(plugin.currentScale())
      }
    }
  }

  Item {
    id: overlayRoot
    parent: plugin.mainWindow ? plugin.mainWindow.contentItem : null
    anchors.fill: parent
    visible: plugin.scaleBoxVisible

    Rectangle {
      id: scaleBackground

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
          if (!scaleField.activeFocus && plugin.scaleBoxVisible) {
            scaleField.text = plugin.formatScaleNumber(plugin.currentScale())
          }
        }
      }
    }
  }
}
