import QtQuick
import QtQuick.Controls
import org.qfield
import Theme

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property string debugText: "Starter diagnose ..."

  function probeValue(label, getter) {
    try {
      var value = getter()
      if (value === undefined)
        return label + ": undefined"
      if (value === null)
        return label + ": null"
      return label + ": " + value.toString()
    } catch (e) {
      return label + ": ERROR -> " + e
    }
  }

  function refreshDebug() {
    var lines = []

    lines.push(probeValue("iface", function() { return iface }))
    lines.push(probeValue("mainWindow", function() { return iface.mainWindow() }))
    lines.push(probeValue("mainWindow.contentItem", function() { return iface.mainWindow().contentItem }))
    lines.push(probeValue("mapCanvas", function() { return iface.mapCanvas() }))
    lines.push(probeValue("mapSettings", function() { return iface.mapCanvas().mapSettings }))
    lines.push(probeValue("scale", function() { return iface.mapCanvas().mapSettings.scale }))
    lines.push(probeValue("extent.width", function() { return iface.mapCanvas().mapSettings.extent.width }))
    lines.push(probeValue("extent.height", function() { return iface.mapCanvas().mapSettings.extent.height }))
    lines.push(probeValue("mapCanvasWrapper", function() { return iface.mapCanvas().mapCanvasWrapper }))

    debugText = lines.join("\n")
    console.log(debugText)
  }

  Timer {
    interval: 1000
    repeat: true
    running: true
    onTriggered: plugin.refreshDebug()
  }

  Component.onCompleted: refreshDebug()

  Item {
    id: overlayRoot
    parent: plugin.mainWindow ? plugin.mainWindow.contentItem : null
    anchors.fill: parent

    Rectangle {
      anchors {
        top: parent.top
        topMargin: 12
        left: parent.left
        leftMargin: 12
      }

      width: Math.min(parent.width - 24, 700)
      height: 220
      radius: 6
      color: "white"
      opacity: 0.92
      border.color: Theme.mainColor
      border.width: 1

      Flickable {
        anchors.fill: parent
        anchors.margins: 8
        contentWidth: width
        contentHeight: debugColumn.height
        clip: true

        Column {
          id: debugColumn
          width: parent.width
          spacing: 6

          Text {
            text: "QField plugin diagnose"
            font.bold: true
            font.pixelSize: 16
            color: Theme.textColor
          }

          Text {
            width: parent.width
            wrapMode: Text.WrapAnywhere
            text: plugin.debugText
            font.family: "monospace"
            font.pixelSize: 12
            color: Theme.textColor
          }
        }
      }
    }
  }
}
