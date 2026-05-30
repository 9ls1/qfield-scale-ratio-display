import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: scaleRatioDisplay

  // Styrer om målestokkboksen vises eller skjules
  property bool scaleBoxVisible: true

  // Egen horisontal og vertikal padding.
  // Litt mindre vertikal padding gjør boksen mindre "luftig" oppe og nede.
  property int boxPaddingX: 6
  property int boxPaddingY: 3

  // Felles stilverdier for både målestokkboks og toggle-knapp
  property color panelBorderColor: Theme.mainColor
  property real panelOpacity: 0.7
  property int panelRadius: 4
  property int panelBorderWidth: 1

  // Henter gjeldende målestokk fra kartet
  function currentScale() {
    return iface.mapCanvas().mapSettings.scale
  }

  // Formaterer målestokkstall:
  // 9876  -> "9876"
  // 10000 -> "10 000"
  // 16789 -> "16 789"
  function formatScaleNumber(value) {
    var rounded = Math.round(value)
    if (rounded >= 10000) {
      return rounded.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
    }
    return rounded.toString()
  }

  // Fjerner mellomrom før tallet tolkes
  function unformatScaleNumber(text) {
    return text.replace(/\s/g, "")
  }

  // Setter ny målestokk basert på tallet brukeren skriver inn
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

    // I QField/QML er center en property
    var center = extent.center

    try {
      canvas.mapCanvasWrapper.zoomScale(center, newScale, false)

      // Etter endring viser vi tallet formattert igjen
      scaleField.text = formatScaleNumber(newScale)
      scaleField.focus = false
    } catch (e) {
      console.log("zoomScale failed: " + e)
      iface.mainWindow().displayToast("Kunne ikke sette målestokk")
    }
  }

  // Målestokkboksen midt øverst
  Rectangle {
    id: scaleBackground
    visible: scaleBoxVisible

    anchors {
      top: parent.top
      topMargin: 10
      horizontalCenter: parent.horizontalCenter
    }

    // Litt mer sidepadding enn topp/bunn gir et mer balansert uttrykk
    width: scaleRow.implicitWidth + (boxPaddingX * 2)
    height: scaleRow.implicitHeight + (boxPaddingY * 2)

    color: "white"
    opacity: panelOpacity
    radius: panelRadius

    border {
      color: panelBorderColor
      width: panelBorderWidth
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

        // Bredde følger antall sifre
        width: Math.max(36, contentWidth + 4)

        // Litt lavere felt for å redusere luft oppe og nede
        height: 26

        font.pixelSize: 18
        font.bold: true
        color: Theme.textColor
        text: formatScaleNumber(currentScale())

        inputMethodHints: Qt.ImhDigitsOnly
        selectByMouse: true
        horizontalAlignment: TextInput.AlignRight

        // Fjern intern padding for et kompakt uttrykk
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        // Ingen ekstra feltbakgrunn
        background: Rectangle {
          color: "transparent"
          border.width: 0
        }

        // Ved fokus: vis rått tall uten mellomrom
        // Når fokus forsvinner: bruk verdien og formatter på nytt
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

    // Oppdater visningen automatisk hvis kartet zoomes på andre måter
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
    height: scaleBackground.height
    radius: panelRadius

    color: "white"
    opacity: panelOpacity

    border {
      color: panelBorderColor
      width: panelBorderWidth
    }

    Text {
      anchors.centerIn: parent
      text: "1:n"
      font.pixelSize: 16
      font.bold: true
      color: scaleBoxVisible ? "black" : "gray"
    }

    // Skråstrek når målestokkboksen er skjult
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
    // Legg komponentene inn i QField-vinduet
    iface.mainWindow().contentItem.children.push(scaleBackground)
    iface.mainWindow().contentItem.children.push(toggleButton)
  }
}
}