import QtQuick
import qs.Commons
import qs.Ui

// One color setting: a live swatch, its label, and a hex field. `effective` is
// the color the bar is actually using right now (theme or override); the field
// follows it until the user starts typing, and `commit` fires with the typed
// text when they finish.
Row {
  id: root

  property string label: ""
  property string key: ""
  property color effective: "transparent"
  property bool overridden: false
  readonly property bool editing: input.activeFocus

  signal commit(string key, string value)
  signal closeRequested()

  spacing: Style.space(10)

  function hex(c) {
    function ch(v) {
      var s = Math.round(Math.max(0, Math.min(1, v)) * 255).toString(16)
      return s.length < 2 ? "0" + s : s
    }
    return "#" + ch(c.r) + ch(c.g) + ch(c.b)
  }

  // Show the effective color in the field, unless the user is mid-edit.
  function sync() {
    if (!input.activeFocus) input.text = root.hex(root.effective)
  }
  onEffectiveChanged: sync()
  Component.onCompleted: sync()

  Rectangle {
    width: input.implicitHeight
    height: input.implicitHeight
    radius: Style.cornerRadius
    color: root.effective
    border.width: 1
    border.color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.4)
  }

  Text {
    width: Style.space(84)
    anchors.verticalCenter: parent.verticalCenter
    text: root.label + (root.overridden ? " •" : "")
    color: Color.foreground
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  TextField {
    id: input
    width: root.width - x
    placeholderText: "#rrggbb"
    selectByMouse: true
    validator: RegularExpressionValidator { regularExpression: /^#?[0-9a-fA-F]{0,6}$/ }

    onEditingFinished: {
      var value = text.trim()
      if (value === "" || value.toLowerCase() === root.hex(root.effective)) return root.sync()
      root.commit(root.key, value)
    }
    Keys.onEscapePressed: {
      root.sync()
      root.closeRequested()
    }
  }
}
