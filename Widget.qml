import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Omarchy bar widget: a palette glyph that opens a small panel for the bar's
// background and foreground colors. Colors are written to the [bar] section of
// ~/.config/omarchy/shell.toml by the bundled `bar-colors` script; the shell
// watches that file, so the bar repaints as soon as the script exits, and the
// override survives theme switches.
Panel {
  id: root
  moduleName: "dev.csfh.rebar"
  ipcTarget: "dev.csfh.rebar"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string script: String(Qt.resolvedUrl("bar-colors")).replace(/^file:\/\//, "")

  // Keys the user has overridden ("background", "text"); empty means the bar
  // is following the theme.
  property var overrides: ({})
  property string errorText: ""
  readonly property bool hasOverrides: !!(overrides.background || overrides.text)

  // Center spacer state, as reported by `bar-colors get`.
  property bool spacerOn: false
  property int spacerWidth: 40

  // Run `bar-colors <args>`; the change reaches the bar through the file watcher.
  function run(args) {
    errorText = ""
    runner.command = [root.script].concat(args)
    runner.running = true
  }

  function refresh() {
    reader.running = true
  }

  Process {
    id: runner
    stderr: StdioCollector { id: runnerErr }
    onExited: function(code) {
      if (code !== 0) root.errorText = runnerErr.text.replace(/^bar-colors:\s*/, "").trim()
      root.refresh()
      bgRow.sync()
      fgRow.sync()
    }
  }

  Process {
    id: reader
    command: [root.script, "get"]
    stdout: StdioCollector {
      onStreamFinished: {
        var found = {}
        text.split("\n").forEach(function(line) {
          var kv = line.match(/^([a-z-]+)=(.+)$/)
          if (kv) found[kv[1]] = kv[2]
        })
        root.overrides = found
        root.spacerOn = found.spacer === "on"
        // Don't fight the user while they are typing a width.
        if (found["spacer-width"] && !widthField.field.activeFocus) root.spacerWidth = parseInt(found["spacer-width"])
      }
    }
  }

  onOpenedChanged: if (opened) refresh()
  Component.onCompleted: refresh()

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰏘" // nf-md-palette
    tooltipText: "Bar colors"
    onPressed: function(b) { root.toggle() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keys

    contentWidth: Style.space(300)
    contentHeight: content.implicitHeight + verticalContentInset

    PanelKeyCatcher {
      id: keys
      anchors.fill: parent
      blocked: bgRow.editing || fgRow.editing || widthField.field.activeFocus
      onCloseRequested: root.close()

      Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(8)

        PanelSectionHeader { text: "BAR COLORS" }

        HexColorRow {
          id: bgRow
          width: parent.width
          label: "Background"
          key: "background"
          effective: Color.bar.background
          overridden: !!root.overrides.background
          onCommit: function(key, value) { root.run(["set", key, value]) }
          onCloseRequested: root.close()
        }

        HexColorRow {
          id: fgRow
          width: parent.width
          label: "Foreground"
          key: "foreground"
          effective: Color.bar.text
          overridden: !!root.overrides.text
          onCommit: function(key, value) { root.run(["set", key, value]) }
          onCloseRequested: root.close()
        }

        Text {
          visible: !!root.bar && root.bar.transparent
          width: parent.width
          wrapMode: Text.WordWrap
          text: "The bar is transparent, so it ignores these colors and picks its own text color from the wallpaper."
          color: Color.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }

        Button {
          visible: !!root.bar && root.bar.transparent
          width: parent.width
          text: "Make the bar opaque"
          bordered: true
          onClicked: root.run(["transparent", "false"])
        }

        PanelSeparator {}

        PanelSectionHeader { text: "CENTER SPACER" }

        Toggle {
          width: parent.width
          label: "Gap in the center"
          description: "Leaves a space exactly in the middle of the bar"
          checked: root.spacerOn
          onClicked: root.run(["spacer", root.spacerOn ? "off" : "on", String(root.spacerWidth)])
        }

        NumberField {
          id: widthField
          label: "Width (px)"
          from: 1
          to: 2000
          stepSize: 4
          value: root.spacerWidth
          enabled: root.spacerOn
          opacity: root.spacerOn ? 1 : 0.4
          onModified: function(v) {
            root.spacerWidth = v
            widthTimer.restart()
          }
        }

        // Typing or stepping the width fires many changes; apply once it settles.
        Timer {
          id: widthTimer
          interval: 250
          onTriggered: root.run(["spacer", "width", String(root.spacerWidth)])
        }

        Text {
          visible: root.errorText !== ""
          width: parent.width
          wrapMode: Text.WordWrap
          text: root.errorText
          color: Color.urgent
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }

        Button {
          width: parent.width
          text: "Reset to theme"
          bordered: true
          enabled: root.hasOverrides
          onClicked: root.run(["reset"])
        }
      }
    }
  }
}
