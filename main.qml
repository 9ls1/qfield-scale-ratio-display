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
    
    width: scaleTextLabel.width + 8
    height: scaleTextLabel.height + 6
    
    color: Theme.white
    opacity: 0.7
    radius: 4
    
    border {
      color: Theme.mainColor
      width: 1
    }
    
    Text {
      id: scaleTextLabel
      
      anchors {
        centerIn: parent
      }
      
      // font.pixelSize: Theme.hugeDefaultFontSize + 12
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
  }

  Component.onCompleted: {
    // Add scale background to main window
    iface.mainWindow().contentItem.children.push(scaleBackground)
    
    iface.mainWindow().displayToast('Scale Ratio Display plugin loaded')
  }
}
