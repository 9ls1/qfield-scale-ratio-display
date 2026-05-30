import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: scaleRatioDisplay

  // Styrer om målestokkboksen vises eller skjules
  property bool scaleBoxVisible: true

  // Felles padding rundt innholdet i målestokkboksen.
  // Samme verdi brukes horisontalt og vertikalt for å gi lik marg på alle sider.
  property int boxPadding: 6

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

  // Fjerner mellomrom før tallet tolkes
  function unformatScaleNumber(text) {
    return text.replace(/\s/g, "")
  }

  // Setter ny målestokk ut fra verdien i tekstfeltet
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

    // I QField/QML er center en property, ikke en funksjon
    var center = extent.center

    try {
      // Zoomer til ønsket målestokk
      canvas.mapCanvasWrapper.zoomScale(center, newScale, false)

      // Vis formattert verdi etter at målestokken er satt
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

    // Lik padding på alle sider:
    // + 2 * boxPadding gir samme luft venstre/høyre og oppe/nede
    width: scaleRow.implicitWidth + (boxPadding * 2)
    height: scaleRow.implicitHeight + (boxPadding * 2)

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

      // Fast prefiks
      Text {
        id: scalePrefix
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 18
        font.bold: true
        color: Theme.textColor
        text: "1 :"
      }

      // Redigerbart målestokkstall
      TextField {
        id: scaleField
        anchors.verticalCenter: parent.verticalCenter

        // Auto-bredde etter antall sifre
        width: Math.max(36, contentWidth + 4)
        height: 30

        font.pixelSize: 18
        font.bold: true
        color: Theme.textColor

        // Startverdi vises formattert
        text: formatScaleNumber(currentScale())

        inputMethodHints: Qt.ImhDigitsOnly
        selectByMouse: true

        // Høyrestilt tekst gjør at tallet legger seg pent tett inntil "1 :"
        horizontalAlignment: TextInput.AlignRight

        // Fjerner intern padding for å få et strammere uttrykk
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        // Gjør at tekstfeltet visuelt blir en del av samme boks
        background: Rectangle {
          color: "transparent"
          border.width: 0
        }

        // Når feltet får fokus, vis rått tall uten mellomrom
        onActiveFocusChanged: {
          if (activeFocus) {
            scaleField.text = Math.round(currentScale()).toString()
            scaleField.selectAll()
          } else {
            applyScale()
          }
        }

        // Enter/OK setter ny målestokk
        onAccepted: applyScale()
      }
    }

    // Oppdaterer feltet automatisk hvis brukeren zoomer på andre måter
    Connections {
      target: iface.mapCanvas().mapSettings

      function onExtentChanged() {
        if (!scaleField.activeFocus) {
          scaleField.text = formatScaleNumber(currentScale())
        }
      }
    }
  }

  // Knapp øverst til høyre for å vise/skjule målestokkboksen
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

    // Grå skråstrek når boksen er skjult
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
    // Legger komponentene inn i hovedvinduet
    iface.mainWindow().contentItem.children.push(scaleBackground)
    iface.mainWindow().contentItem.children.push(toggleButton)
  }
}