import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: scaleRatioDisplay

  function currentScale() {
    return iface.mapCanvas().mapSettings.scale
  }

  function applyScale() {
    if (scaleField.text === "" || scaleField.text === "0")
      return

    var newScale = parseFloat(scaleField.text)
    if (isNaN(newScale) || newScale <= 0) {
      iface.mainWindow().displayToast("Ugyldig målestokk")
      return
    }

    var canvas = iface.mapCanvas()
    var mapSettings = canvas.mapSettings
    var extent = mapSettings.extent
    var center = extent.center

    try {
      canvas.mapCanvasWrapper.zoomScale(center, newScale, false)
      scaleField.focus = false
    } catch (e) {
      console.log("zoomScale failed: " + e)
      iface.mainWindow().displayToast("Kunne ikke sette målestokk")
    }
  }

  Rectangle {
    id: scaleBackground

    anchors {
      top: parent.top
      topMargin: 10
      horizontalCenter: parent.horizontalCenter
    }

    width: scaleRow.implicitWidth + 12
    height: scaleRow.implicitHeight + 10

    color: Theme.white
    opacity: 0.7
    radius: 4

    border {
      color: Theme.mainColor
      width: 1
    }

    Row {
      id: scaleRow
      anchors.centerIn: parent
      spacing: 1

      Text {
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 18
        font.bold: true
        color: Theme.textColor
        text: "1 :"
      }

      TextField {
        id: scaleField
        anchors.verticalCenter: parent.verticalCenter
        width: 72
        height: 30

        font.pixelSize: 18
        color: Theme.textColor
        text: Math.round(currentScale()).toString()
        inputMethodHints: Qt.ImhDigitsOnly
        selectByMouse: true

        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        background: Rectangle {
          color: "transparent"
          border.width: 0
        }

        onAccepted: applyScale()

        onActiveFocusChanged: {
          if (!activeFocus) {
            applyScale()
          }
        }
      }
    }

    Connections {
      target: iface.mapCanvas().mapSettings

      function onExtentChanged() {
        if (!scaleField.activeFocus) {
          scaleField.text = Math.round(currentScale()).toString()
        }
      }
    }
  }

  Component.onCompleted: {
    iface.mainWindow().contentItem.children.push(scaleBackground)
  }
}