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
          
          function onMapSettingsChanged() {
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
            
            onEditingFinished: applyScale()
            
            Keys.onReturnPressed: {
              applyScale()
              focus = false
            }
            
            Keys.onEnterPressed: {
              applyScale()
              focus = false
            }
            
            function applyScale() {
              if (text !== "" && text !== "0") {
                var newScale = parseFloat(text)
                if (newScale > 0) {
                  iface.mapCanvas().mapSettings.scale = newScale
                  scaleTextLabel.text = formatScale(newScale)
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
