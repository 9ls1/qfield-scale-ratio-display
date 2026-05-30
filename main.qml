import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

// Plassering: Endre anchors (top/bottom, left/right)
// Størrelse: Endre font.pixelSize
// Bakgrunnsfarge: Endre color i Rectangle
// Desimalplasser: Endre Math.round() til toFixed(1) for å vise f.eks. "1:500.5"

Item {
  id: scaleRatioDisplay

  // Funksjon for å formatere tallet med mellomrom
  function formatScale(scale) {
    var roundedScale = Math.round(scale)
    
    // Legg til mellomrom hvis tallet er større enn 4999
    if (roundedScale > 9999) {
      return "1 : " + roundedScale.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
    } else {
      return "1 : " + roundedScale
    }
  }

  Rectangle {
    id: scaleBackground
    
    anchors {
      top: parent.top
      topMargin: 10
      horizontalCenter: parent.horizontalCenter
    }
    
    width: Math.max(scaleTextLabel.width, scaleInput.width) + 16
    height: scaleTextLabel.height + scaleInput.height + 16
    
    color: Theme.white
    opacity: 0.7
    radius: 4
    
    border {
      color: Theme.mainColor
      width: 1
    }

    Column {
      anchors {
        centerIn: parent
        margins: 4
      }
      spacing: 4

      Text {
        id: scaleTextLabel
        
        anchors.horizontalCenter: parent.horizontalCenter
        
        font.pixelSize: 20
        font.bold: true
        color: Theme.textColor
        
        text: formatScale(iface.mapCanvas().mapSettings.scale)
        
        // Update scale text whenever map scale changes
        Connections {
          target: iface.mapCanvas()
          
          function onScaleChanged() {
            scaleTextLabel.text = formatScale(iface.mapCanvas().mapSettings.scale)
          }
          
          function onMapSettingsChanged() {
            scaleTextLabel.text = formatScale(iface.mapCanvas().mapSettings.scale)
          }
        }
      }

      Rectangle {
        id: inputContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: 150
        height: 32
        color: Theme.white
        border.color: Theme.mainColor
        border.width: 1
        radius: 2

        TextInput {
          id: scaleInput
          
          anchors {
            fill: parent
            margins: 4
          }
          
          font.pixelSize: 14
          color: Theme.textColor
          text: Math.round(iface.mapCanvas().mapSettings.scale).toString()
          inputMethodHints: Qt.ImhDigitsOnly
          
          onEditingFinished: {
            if (text !== "") {
              var newScale = parseFloat(text)
              if (newScale > 0) {
                iface.mapCanvas().mapSettings.scale = newScale
                scaleTextLabel.text = formatScale(newScale)
              }
            }
          }
        }

        Text {
          anchors {
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
          }
          
          font.pixelSize: 12
          color: Theme.textColor
          text: "1:"
        }
      }
    }
  }

  Component.onCompleted: {
    // Add scale background to main window
    iface.mainWindow().contentItem.children.push(scaleBackground)
    
    iface.mainWindow().displayToast('Scale Ratio Display plugin loaded')
  }
}
