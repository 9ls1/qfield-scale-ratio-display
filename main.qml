import QtQuick
import QtQuick.Controls

import org.qfield
import Theme

Item {
  id: plugin

  // Reference to the QField main window.
  // Used for toast messages and as parent for the overlay UI.
  property var mainWindow: iface.mainWindow()

  // Controls whether the scale box overlay is currently visible.
  // The overlay is toggled from the plugin toolbar button.
  property bool scaleBoxVisible: false

  // Internal padding inside the scale box.
  property int boxPaddingX: 5
  property int boxPaddingY: 2

  // Layout-driven adaptation:
  // We do not detect platform/device type directly.
  // Instead, we infer when the UI likely runs on a small phone-like screen
  // by checking whether the window is in portrait orientation and narrow.
  property bool isPortrait: mainWindow && mainWindow.height > mainWindow.width
  property bool isSmallScreen: mainWindow && Math.min(mainWindow.width, mainWindow.height) < 500

  // Extra top margin for small portrait screens.
  // This helps avoid placing the scale box under notches / camera cutouts.
  property int overlayTopMargin: (isPortrait && isSmallScreen) ? 56 : 10

  // Returns the current map scale from the active map canvas.
  // If anything fails, 0 is returned to avoid plugin crashes.
  function currentScale() {
    try {
      return iface.mapCanvas().mapSettings.scale
    } catch (e) {
      return 0
    }
  }

  // Formats the scale number for display.
  // Examples:
  //   9876   -> "9876"
  //   10000  -> "10 000"
  function formatScaleNumber(value) {
    var rounded = Math.round(value)
    if (rounded >= 10000) {
      return rounded.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
    }
    return rounded.toString()
  }

  // Removes spaces from user-entered scale text before parsing.
  // Example:
  //   "10 000" -> "10000"
  function unformatScaleNumber(text) {
    return text.replace(/\s/g, "")
  }

  // Applies a user-entered scale value to the map.
  // Keeps the current map center and zooms to the requested scale.
  function applyScale() {
    var rawText = unformatScaleNumber(scaleField.text)

    // Ignore empty values and zero.
    if (rawText === "" || rawText === "0")
      return

    var newScale = parseFloat(rawText)
    if (isNaN(newScale) || newScale <= 0) {
      mainWindow.displayToast("Invalid scale")
      return
    }

    try {
      var canvas = iface.mapCanvas()
      var extent = canvas.mapSettings.extent
      var center = extent.center

      // Zoom to the requested scale around the current center.
      canvas.mapCanvasWrapper.zoomScale(center, newScale, false)

      // Reformat the text after successful zoom.
      scaleField.text = formatScaleNumber(newScale)
      scaleField.focus = false
    } catch (e) {
      console.log("zoomScale failed: " + e)
      mainWindow.displayToast("Could not set scale")
    }
  }

  // When the plugin is loaded, add a round button to QField's plugin toolbar.
  // This is the key to getting the desired behavior:
  // the toolbar button only appears when a project is open in QField.
  Component.onCompleted: {
    iface.addItemToPluginsToolbar(pluginButton)
  }

  // Toolbar button used to toggle the scale box overlay.
  // The icon comes from scale.svg and should represent the "1:n" symbol.
  QfToolButton {
    id: pluginButton
    iconSource: "scale.svg"
    iconColor: Theme.mainColor
    bgcolor: Theme.darkGray
    round: true

    onClicked: {
      plugin.scaleBoxVisible = !plugin.scaleBoxVisible

      // Refresh the displayed value when the box is opened.
      if (plugin.scaleBoxVisible) {
        scaleField.text = plugin.formatScaleNumber(plugin.currentScale())
      }
    }
  }

  // Overlay root placed above the main content area.
  // This allows the scale box to float over the map.
  Item {
    id: overlayRoot
    parent: plugin.mainWindow ? plugin.mainWindow.contentItem : null
    anchors.fill: parent

    // The entire overlay is shown/hidden by the toolbar button.
    visible: plugin.scaleBoxVisible

    // Main scale display box.
    Rectangle {
      id: scaleBackground

      anchors {
        top: parent.top
        topMargin: plugin.overlayTopMargin
        horizontalCenter: parent.horizontalCenter
      }

      // Size follows content plus padding.
      width: scaleRow.width + (plugin.boxPaddingX * 2)
      height: scaleRow.height + (plugin.boxPaddingY * 2)

      color: Theme.white
      opacity: 0.6
      radius: 4

      border {
        color: Theme.mainColor
        width: 1
      }

      // Content row: static "1 :" label + editable scale value.
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

          // Width adapts to content but never becomes too small.
          width: Math.max(36, contentWidth + 4)
          height: 24

          font.pixelSize: 18
          font.bold: true
          color: Theme.textColor

          // Initial display value.
          text: plugin.formatScaleNumber(plugin.currentScale())

          // Hint numeric input for virtual keyboards.
          inputMethodHints: Qt.ImhDigitsOnly
          selectByMouse: true
          horizontalAlignment: TextInput.AlignRight

          // Remove extra internal padding to keep the field compact.
          leftPadding: 0
          rightPadding: 0
          topPadding: 0
          bottomPadding: 0

          // Transparent background so the field blends into the box.
          background: Rectangle {
            color: "transparent"
            border.width: 0
          }

          // When editing starts:
          // - show the raw integer scale without grouping spaces
          // - select all text for quick replacement
          //
          // When editing ends:
          // - try to apply the new scale
          onActiveFocusChanged: {
            if (activeFocus) {
              scaleField.text = Math.round(plugin.currentScale()).toString()
              scaleField.selectAll()
            } else {
              plugin.applyScale()
            }
          }

          // Pressing Enter / OK applies the scale immediately.
          onAccepted: plugin.applyScale()
        }
      }

      // Keep the displayed number in sync when the map extent changes
      // through other navigation methods such as pinch zoom or mouse wheel.
      // Do not overwrite the field while the user is actively editing it.
      Connections {
        target: iface.mapCanvas() ? iface.mapCanvas().mapSettings : null

        function onExtentChanged() {
          if (!scaleField.activeFocus && plugin.scaleBoxVisible) {
            scaleField.text = plugin.formatScaleNumber(plugin.currentScale())
          }
        }
      }
    }
  }
}
