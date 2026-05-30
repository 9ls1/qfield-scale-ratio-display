import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: scaleRatioDisplay

  function currentScale() {
    return iface.mapCanvas().mapSettings.scale
  }

  function formatScale(scale) {
    var roundedScale = Math.round(scale)
    if (roundedScale > 9999) {
      return "1 : " + roundedScale.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
    }
    return "1 : " + roundedScale
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

    width: Math.max(scaleTextLabel.width, inputContainer.width) + 16
    height: scaleTextLabel.height + inputContainer.height + 24

    color: Theme.white
    opacity: 0.7
    radius: 4

    border {
      color: Theme.mainColor
      width: 1
    }

    Column {
      anchors.centerIn: parent
      spacing: 8

      Text {
        id: scaleTextLabel
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 20
        font.bold: true
        color: Theme.textColor
        text: formatScale(currentScale())

        Connections {
          target: iface.mapCanvas().mapSettings

          function onExtentChanged() {
            scaleTextLabel.text = formatScale(currentScale())
            if (!scaleField.activeFocus) {
              scaleField.text = Math.round(currentScale()).toString()
            }
          }
        }
      }

      Rectangle {
        id: inputContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: 180
        height: 36
        color: Theme.white
        border.color: Theme.mainColor
        border.width: 1
        radius: 2

        Row {
          anchors.fill: parent
          anchors.margins: 4
          spacing: 4

          Text {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: Theme.textColor
            text: "1:"
            width: 24
          }

          TextField {
            id: scaleField
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 28
            height: parent.height

            font.pixelSize: 14
            color: Theme.textColor
            text: Math.round(currentScale()).toString()
            inputMethodHints: Qt.ImhDigitsOnly
            selectByMouse: true

            onAccepted: applyScale()

            onActiveFocusChanged: {
              if (!activeFocus) {
                applyScale()
              }
            }
          }
        }
      }
    }
  }

  Component.onCompleted: {
    iface.mainWindow().contentItem.children.push(scaleBackground)
    iface.mainWindow().displayToast("Scale Ratio Display plugin loaded")
  }
}