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
            
            // DEBUG: Skriv ut når noe skjer
            onTextChanged: {
              console.log("TextInput changed: " + text)
            }
            
            onEditingFinished: {
              console.log("onEditingFinished triggered with value: " + text)
              applyScale()
            }
            
            Keys.onReturnPressed: {
              console.log("Return pressed with value: " + text)
              applyScale()
              event.accepted = true
              focus = false
            }
            
            Keys.onEnterPressed: {
              console.log("Enter pressed with value: " + text)
              applyScale()
              event.accepted = true
              focus = false
            }
            
            function applyScale() {
              console.log("applyScale() called")
              console.log("Text value: " + text)
              console.log("iface available: " + (typeof iface !== 'undefined'))
              console.log("mapCanvas available: " + (iface && typeof iface.mapCanvas !== 'undefined'))
              
              if (text !== "" && text !== "0") {
                var newScale = parseFloat(text)
                console.log("Parsed scale: " + newScale)
                
                if (newScale > 0) {
                  console.log("Setting scale to: " + newScale)
                  
                  try {
                    iface.mapCanvas().mapSettings.scale = newScale
                    console.log("Scale property set successfully")
                  } catch (e) {
                    console.log("ERROR setting scale: " + e)
                  }
                  
                  scaleTextLabel.text = formatScale(newScale)
                  iface.mainWindow().displayToast('Scale set to 1:' + newScale)
                  console.log("Toast message sent")
                }
              }
            }
          }
        }
      }
    }
  }

  Component.onCompleted: {
    console.log("=== Scale Ratio Display LOADING ===")
    console.log("iface type: " + typeof iface)
    console.log("iface.mapCanvas type: " + typeof iface.mapCanvas)
    
    try {
      var canvas = iface.mapCanvas()
      console.log("mapCanvas retrieved successfully")
      console.log("mapSettings.scale: " + canvas.mapSettings.scale)
    } catch (e) {
      console.log("ERROR accessing mapCanvas: " + e)
    }
    
    iface.mainWindow().contentItem.children.push(scaleBackground)
    iface.mainWindow().displayToast('Scale Ratio Display plugin loaded')
    console.log("=== Scale Ratio Display LOADED ===")
  }
}
