import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: scaleRatioDisplay

  // Styrer om målestokkboksen vises
  property bool scaleBoxVisible: true

  // Henter gjeldende målestokk fra kartet
  function currentScale() {
    return iface.mapCanvas().mapSettings.scale
  }

  // Formaterer målestokkstall:
  // 9876  -> "9876"
  // 10000 -> "10 000"
  function formatScaleNumber(value) {
    var rounded = Math.round(value)
    if (rounded >= 10000) {
      return rounded.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
    }
    return rounded.toString()
  }

  // Fjerner mellomrom før parsing
  function unformatScaleNumber(text) {
    return text.replace(/\s/g, "")
  }

  // Setter ny målestokk
  function applyScale() {
    var rawText = unformatScaleNumber(scaleField.text)

    if (rawText === "" || rawText === "0")
      return

    var newScale = parseFloat(rawText)
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
      scaleField.text = formatScaleNumber(newScale)
      scaleField.focus = false
    } catch (e) {
      console.log("zoomScale failed: " + e)
      iface.mainWindow().displayToast("Kunne ikke sette målestokk")
    }
  }

  // Selve målestokkboksen
  Rectangle {
    id: scaleBackground
    visible: scaleBoxVisible

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
        height: 30

        font.pixelSize: 18
        font.bold: true
        color: Theme.textColor
        text: formatScaleNumber(currentScale())

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
            scaleField.text = Math.round(currentScale()).toString()
            scaleField.selectAll()
          } else {
            applyScale()
          }
        }

        onAccepted: applyScale()
      }
    }

    Connections {
      target: iface.mapCanvas().mapSettings

      function onExtentChanged() {
        if (!scaleField.activeFocus) {
          scaleField.text = formatScaleNumber(currentScale())
        }
      }
    }
  }

  // Toggle-knapp øverst til høyre
  Rectangle {
    id: toggleButton

    anchors {
      top: parent.top
      topMargin: 10
      right: parent.right
      rightMargin: 68
    }

    width: 42
    height: 28
    radius: 4

    color: Theme.white
    opacity: 0.7

    border {
      color: Theme.mainColor
      width: 1
    }

    Text {
      anchors.centerIn: parent
      text: "1:n"
      font.pixelSize: 16
      font.bold: true
      color: scaleBoxVisible ? "black" : "gray"
    }

    // Skråstrek over teksten når boksen er skjult
    Rectangle {
      visible: !scaleBoxVisible
      anchors.centerIn: parent
      width: 28
      height: 2
      color: "gray"
      rotation: -30
      antialiasing: true
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        scaleBoxVisible = !scaleBoxVisible
      }
    }
  }

  Component.onCompleted: {
    iface.mainWindow().contentItem.children.push(scaleBackground)
    iface.mainWindow().contentItem.children.push(toggleButton)
  }
}