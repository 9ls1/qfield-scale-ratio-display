import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: scaleRatioDisplay

  // Styrer om målestokkboksen vises eller skjules
  property bool scaleBoxVisible: true

  // Horisontal og vertikal luft inne i målestokkboksen
  property int boxPaddingX: 5
  property int boxPaddingY: 2

  // Henter gjeldende målestokk fra kartet
  function currentScale() {
    return iface.mapCanvas().mapSettings.scale
  }

  // Formaterer målestokkstallet:
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

    var canvas = iface.mapCanvas()
    var extent = canvas.mapSettings.extent
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

  // Målestokkboksen
  Rectangle {
    id: scaleBackground
    visible: scaleBoxVisible

    anchors {
      top: parent.top
      topMargin: 10
      horizontalCenter: parent.horizontalCenter
    }

    // Samme enkle prinsipp som den fungerende gamle versjonen:
    // størrelse basert direkte på innhold + liten fast luft
    width: scaleRow.width + (boxPaddingX * 2)
    height: scaleRow.height + (boxPaddingY * 2)

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

        // Ved redigering vises rått tall uten mellomrom
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

    // Oppdater målestokktallet automatisk ved annen zooming
    Connections {
      target: iface.mapCanvas().mapSettings

      function onExtentChanged() {
        if (!scaleField.activeFocus) {
          scaleField.text = formatScaleNumber(currentScale())
        }
      }
    }
  }

  // Toggle-knapp i øvre høyre hjørne
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
      color: scaleBoxVisible ? "black" : "gray"
    }

    // Skråstrek når boksen er skjult
    Rectangle {
      visible: !scaleBoxVisible
      anchors.centerIn: parent
      width: 24
      height: 2
      color: "gray"
      rotation: -30
      antialiasing: true
    }

    MouseArea {
      anchors.fill: parent
      onClicked: scaleBoxVisible = !scaleBoxVisible
    }
  }

  Component.onCompleted: {
    iface.mainWindow().contentItem.children.push(scaleBackground)
    iface.mainWindow().contentItem.children.push(toggleButton)
  }
}