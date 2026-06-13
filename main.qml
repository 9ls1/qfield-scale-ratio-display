import QtQuick
import QtQuick.Controls
import org.qfield
import org.qgis
import Theme

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property bool projectUiVisible: false

  function hasOpenProject() {
    try {
      if (!ProjectUtils || !ProjectUtils.project)
        return false

      var fn = ProjectUtils.project.fileName
      if (fn === undefined || fn === null)
        return false

      return fn.toString().length > 0
    } catch (e) {
      console.log("hasOpenProject failed: " + e)
      return false
    }
  }

  function refreshVisibility() {
    projectUiVisible = hasOpenProject()
    console.log("projectUiVisible = " + projectUiVisible)
  }

  Timer {
    interval: 500
    repeat: true
    running: true
    onTriggered: plugin.refreshVisibility()
  }

  Component.onCompleted: refreshVisibility()

  Item {
    id: overlayRoot
    parent: plugin.mainWindow ? plugin.mainWindow.contentItem : null
    anchors.fill: parent
    visible: plugin.projectUiVisible

    Rectangle {
      anchors {
        top: parent.top
        topMargin: 12
        horizontalCenter: parent.horizontalCenter
      }

      width: 140
      height: 36
      radius: 6
      color: "#d9f7be"
      border.color: "green"
      border.width: 1
      opacity: 0.9

      Text {
        anchors.centerIn: parent
        text: "PROJECT OPEN"
        font.pixelSize: 16
        font.bold: true
        color: "darkgreen"
      }
    }
  }
}
