import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: scaleRatioDisplay

  function formatScale(scale) {
    var roundedScale = Math.round(scale)
    
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
      anchors {
        centerIn: parent
        margins: 8
      }
      spacing: 8

      Text {
        id: scaleTextLabel
        
        anchors.horizontalCenter: parent.horizontalCenter
        
        font.pixelSize: 20
        font.bold: true
        color: Theme.textColor
        
        text: formatScale(iface.mapCanvas().mapSettings.scale)
        
        Connections {
          target: iface.mapCanvas()
          
          function onScaleChanged() {
            scaleTextLabel.text = formatScale(iface.mapCanvas().mapSettings.scale)
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

          TextInput {
            id: scaleInput
            
            anchors.verticalCenter: parent.verticalCenter
            
            width: parent.width - 28
            height: parent.height
            
            font.pixelSize: 14
            color: Theme.textColor
            text: Math.round(iface.mapCanvas().mapSettings.scale).toString()
            inputMethodHints: Qt.ImhDigitsOnly
            selectByMouse: true
            
            onEditingFinished: applyScale()
            
            Keys.onReturnPressed: {
              applyScale()
              event.accepted = true
              focus = false
            }
            
            Keys.onEnterPressed: {
              applyScale()
              event.accepted = true
              focus = false
            }
            
            function applyScale() {
              console.log("=== DEBUG: applyScale called ===")
              console.log("Text: " + text)
              
              if (text !== "" && text !== "0") {
                var newScale = parseFloat(text)
                console.log("Parsed scale: " + newScale)
                
                if (newScale > 0) {
                  var mapCanvas = iface.mapCanvas()
                  console.log("Available mapCanvas methods:")
                  for (var prop in mapCanvas) {
                    if (typeof mapCanvas[prop] === 'function') {
                      console.log("  Function: " + prop)
                    }
                  }
                  
                  var mapSettings = mapCanvas.mapSettings
                  console.log("Available mapSettings properties:")
                  for (var prop in mapSettings) {
                    console.log("  " + prop)
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  Component.onCompleted: {
    iface.mainWindow().contentItem.children.push(scaleBackground)
    iface.mainWindow().displayToast('Scale Ratio Display plugin loaded')
  }
}
