pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Dialogs
import QtCore

ApplicationWindow {
  id: root
  readonly property bool compactLayout: width < 620
  property bool darkTheme: false
  property bool isExporting: false
  visible: true

  readonly property real a4Width: 210
  readonly property real a4Height: 297
  readonly property real scale: 4
  readonly property real dpi: 96
  readonly property real printWidth: a4Width / 25.4 * dpi * devicePixelRatio
  readonly property real printHeight: a4Height / 25.4 * dpi * devicePixelRatio
  width: a4Width * scale
  height: a4Height * scale
  minimumWidth: 320
  minimumHeight: 568
  // maximumWidth: 320
  // maximumHeight: 568

  readonly property int textFontSize: 20
  readonly property int anchorsMargins: 50
  readonly property int rootColumnLayoutSpacing: anchorsMargins
  readonly property int sectionsColumnLayoutSpacing: anchorsMargins / 10
  readonly property int sectionsItemTopMargin: anchorsMargins
  readonly property int anchorsMarginsCompensation: anchorsMargins * 2
  readonly property int sectionsNameSize: 30
  readonly property int rectangleRadiusSize: 30
  readonly property real gradientStopPosition1: 0.0
  readonly property real gradientStopPosition2: 0.5
  readonly property real gradientStopPosition3: 1.0
  readonly property int experienceMobileBreakpoint: 640
  readonly property int companyIconSize: 50
  readonly property int companyIconCornerRadiusSize: companyIconSize / 5

  title: qsTr("CV")
  color: darkTheme ? "#0b1220" : "#f3f7f6"
  Material.theme: darkTheme ? Material.Dark : Material.Light

  Flickable {
    anchors.fill: parent
    contentWidth: root.width
    contentHeight: rootColumn.implicitHeight + root.anchorsMarginsCompensation
    ScrollBar.vertical: ScrollBar {
      policy: ScrollBar.AsNeeded
    }
    Item {
      id: rootItem
      property bool isExporting: false

      width: isExporting ? root.printWidth : parent.width
      height: rootColumn.implicitHeight + root.anchorsMarginsCompensation
      Rectangle {
        anchors.fill: parent
        color: root.color
        ColumnLayout {
          id: rootColumn
          // NEW — lets PdfExporter find this from C++
          objectName: "rootColumn"
          anchors.fill: parent
          anchors.margins: root.anchorsMargins
          spacing: root.rootColumnLayoutSpacing
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: headerLayout.implicitHeight + root.anchorsMarginsCompensation
            Rectangle {
              id: header
              radius: root.rectangleRadiusSize
              anchors.fill: parent
              gradient: Gradient {
                GradientStop {
                  position: root.gradientStopPosition1
                  color: root.darkTheme ? "#172b4d" : "#dcefe7"
                }
                GradientStop {
                  position: root.gradientStopPosition2
                  color: root.darkTheme ? "#164f63" : "#b7dfcf"
                }
                GradientStop {
                  position: root.gradientStopPosition3
                  color: root.darkTheme ? "#227b68" : "#8cc9ab"
                }
              }

              ColumnLayout {
                id: headerLayout
                anchors.fill: parent
                anchors.margins: root.anchorsMargins
                spacing: root.sectionsColumnLayoutSpacing

                Button {
                  id: themeButton
                  text: root.darkTheme ? qsTr("Light") : qsTr("Dark")
                  hoverEnabled: true
                  Layout.alignment: Qt.AlignHCenter
                  onClicked: root.darkTheme = !root.darkTheme
                  font {
                    pixelSize: root.textFontSize
                  }
                  contentItem: Text {
                    text: themeButton.text
                    color: root.darkTheme ? "#F4FBFF" : "#153047"
                    font: themeButton.font
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                  }
                  background: Rectangle {
                    radius: root.rectangleRadiusSize
                    color: themeButton.hovered ? (root.darkTheme ? "#346178" : "#d4eee2") : (root.darkTheme ? "#24445a" : "#e5f4ed")
                    border.width: 1
                    border.color: root.darkTheme ? "#4d7184" : "#a7d9c0"
                  }
                }

                Button {
                  id: saveAsPdfButton
                  text: qsTr("Save as PDF")
                  hoverEnabled: true
                  Layout.alignment: Qt.AlignHCenter
                  font {
                    pixelSize: root.textFontSize
                  }
                  contentItem: Text {
                    text: saveAsPdfButton.text
                    color: root.darkTheme ? "#F4FBFF" : "#153047"
                    font: saveAsPdfButton.font
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                  }
                  background: Rectangle {
                    radius: root.rectangleRadiusSize
                    color: saveAsPdfButton.hovered ? (root.darkTheme ? "#346178" : "#d4eee2") : (root.darkTheme ? "#24445a" : "#e5f4ed")
                    border.width: 1
                    border.color: root.darkTheme ? "#4d7184" : "#a7d9c0"
                  }
                  onClicked: {
                    const fileName = root.title + ".pdf";
                    if (PdfExporter.isWasm()) {
                      // No FileDialog on web — browser handles the download itself
                      PdfExporter.saveItemAsPdf(rootItem, fileName);
                    } else {
                      saveAsPdfFileDialog.selectedFile = Qt.resolvedUrl(saveAsPdfFileDialog.currentFolder + "/" + fileName);
                      saveAsPdfFileDialog.open();
                    }
                  }
                }

                FileDialog {
                  id: saveAsPdfFileDialog
                  fileMode: FileDialog.SaveFile
                  nameFilters: ["PDF files (*.pdf)"]
                  defaultSuffix: "pdf"
                  currentFolder: StandardPaths.writableLocation(StandardPaths.DownloadLocation)
                  onAccepted: PdfExporter.saveItemAsPdf(rootItem, root.title, saveAsPdfFileDialog.selectedFile)
                }

                Connections {
                  target: PdfExporter
                  function onExportFinished(success, path) {
                    console.log(success ? "Saved: " + path : "Export failed");
                  }
                }

                Item {
                  id: avatar
                  width: 100
                  height: 100
                  Layout.alignment: Qt.AlignHCenter

                  Image {
                    id: logo
                    anchors.fill: parent
                    source: "../../resources/assets/icons/base/light/squared/face-photo.png"
                    sourceSize: Qt.size(100, 100)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                  }

                  Rectangle {
                    id: mask
                    anchors.fill: parent
                    radius: width / 2
                    visible: false
                    layer.enabled: true
                  }

                  MultiEffect {
                    id: maskedLogo
                    anchors.fill: logo
                    source: logo
                    maskEnabled: true
                    maskSource: mask
                  }

                  // Ring on top
                  Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 2
                    height: parent.height + 2
                    radius: width / 2
                    color: "transparent"
                    border.color: "#000"
                    border.width: 2
                    antialiasing: true
                  }
                }

                Text {
                  text: qsTr("CV")
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: headerLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  font {
                    pixelSize: root.sectionsNameSize
                    weight: Font.ExtraBold
                  }
                }

                Text {
                  text: qsTr("ARTURS ANIKINS")
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: headerLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  font {
                    pixelSize: root.textFontSize
                  }
                }

                Text {
                  text: qsTr("C++ Software Developer")
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: headerLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  font {
                    pixelSize: root.textFontSize
                    weight: Font.Bold
                  }
                }

                TextEdit {
                  text: qsTr("<b>Email</b>: xyzdelete\u200B@\u200Bprotonmail\u200B.com")
                  textFormat: TextEdit.RichText
                  readOnly: true
                  selectByMouse: true
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: headerLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  font {
                    pixelSize: root.textFontSize
                  }
                }
                Text {
                  text: qsTr("<b>Website</b>: <u>cv-\u200Barturs-anikins\u200B.netlify.app\u200B</u>")
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: headerLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  font {
                    pixelSize: root.textFontSize
                  }
                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally("https://cv-arturs-anikins.netlify.app")
                  }
                }
                Text {
                  text: qsTr("<b>LinkedIn</b>: <u>linkedin\u200B.com\u200B/in/xyzdelete</u>")
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: headerLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  font {
                    pixelSize: root.textFontSize
                  }
                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally("https://linkedin.com/in/xyzdelete")
                  }
                }
                Text {
                  text: qsTr("<b>GitHub</b>: <u>github.com\u200B/xyzdelete</u>")
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: headerLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  font {
                    pixelSize: root.textFontSize
                  }
                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally("https://github.com/xyzdelete")
                  }
                }
                Text {
                  text: qsTr("I am a citizen of Latvia (EU / EAA), and I currently live in Riga, Latvia.")
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: headerLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  font {
                    pixelSize: root.textFontSize
                  }
                }
              }
            }
          }
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: summaryLayout.implicitHeight + root.anchorsMarginsCompensation
            Rectangle {
              radius: root.rectangleRadiusSize
              anchors.fill: parent
              gradient: Gradient {
                GradientStop {
                  position: root.gradientStopPosition1
                  color: root.darkTheme ? "#172b4d" : "#dceaf7"
                }
                GradientStop {
                  position: root.gradientStopPosition2
                  color: root.darkTheme ? "#1d4770" : "#b9d5ec"
                }
                GradientStop {
                  position: root.gradientStopPosition3
                  color: root.darkTheme ? "#286b91" : "#8dbbdc"
                }
              }

              ColumnLayout {
                id: summaryLayout
                anchors.fill: parent
                anchors.margins: root.anchorsMargins
                spacing: root.sectionsColumnLayoutSpacing

                Text {
                  text: qsTr("Summary")
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: summaryLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  font {
                    pixelSize: root.sectionsNameSize
                    weight: Font.ExtraBold
                  }
                }

                Text {
                  text: qsTr("I am a software developer and I have years of experience in programming. My main tool is C++ (latest standard) but I also have knowledge about latest Qt, QML, CMake, Git, Python, Docker, cross-compilation, WebAssembly and many other tools including AI tools. I'm agile and always ready to learn. By nature, I am a perfectionist and I have QA-like attention to detail. In addition, I have some knowledge about JavaScript and web development. I have experience working in Windows, macOS, Linux, Android, iOS environments. Furthermore, I like computer games and experimenting with Unreal Engine 5.")
                  color: root.darkTheme ? "#F4FBFF" : "#153047"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: summaryLayout.width
                  Layout.topMargin: root.sectionsItemTopMargin
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                  }
                }
              }
            }
          }
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: skillsAndToolsLayout.implicitHeight + root.anchorsMarginsCompensation
            Rectangle {
              radius: root.rectangleRadiusSize
              anchors.fill: parent
              gradient: Gradient {
                GradientStop {
                  position: root.gradientStopPosition1
                  color: root.darkTheme ? "#202044" : "#e9e1f5"
                }
                GradientStop {
                  position: root.gradientStopPosition2
                  color: root.darkTheme ? "#46376c" : "#d0bde5"
                }
                GradientStop {
                  position: root.gradientStopPosition3
                  color: root.darkTheme ? "#705493" : "#b394cf"
                }
              }

              ColumnLayout {
                id: skillsAndToolsLayout
                anchors.fill: parent
                anchors.margins: root.anchorsMargins
                spacing: root.sectionsColumnLayoutSpacing

                Text {
                  text: qsTr("Skills and tools")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignHCenter
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignHCenter
                  font {
                    pixelSize: root.sectionsNameSize
                    weight: Font.ExtraBold
                  }
                }

                Text {
                  text: qsTr("Programming languages I used:")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  Layout.topMargin: root.sectionsItemTopMargin
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                    weight: Font.Bold
                  }
                }
                Text {
                  text: qsTr("• C++ (my main tool) • C • Python • JavaScript")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                  }
                }

                Text {
                  text: qsTr("Integrated development environment (IDE) I used:")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  Layout.topMargin: root.sectionsItemTopMargin
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                    weight: Font.Bold
                  }
                }
                Text {
                  text: qsTr("• Visual Studio Code (my main tool) • Visual Studio • Xcode • Qt Creator")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                  }
                }

                Text {
                  text: qsTr("Environments for which I developed software:")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  Layout.topMargin: root.sectionsItemTopMargin
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                    weight: Font.Bold
                  }
                }
                Text {
                  text: qsTr("• Windows • macOS • Linux • Android • iOS")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                  }
                }

                Text {
                  text: qsTr("Other tools I used:")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  Layout.topMargin: root.sectionsItemTopMargin
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                    weight: Font.Bold
                  }
                }
                Text {
                  text: qsTr("• Git • CMake • Docker • Qt • QML • WebAssembly • GitLab • GitHub • AI tools • Ninja • CMake presets • CPack • vcpkg • Bash • Qt Quick • MSVC • Anaconda • Jira • Slack • Pycharm • PySide6 • QtDesigner • GitKraken Legendary Git Tools | GitKraken • HTML • Cascading Style Sheets (CSS) • Sass • MongoDB • SQLite • Express.js • Node.js • React.js • Postman • JUCE Framework • Microsoft Office • Unreal Engine 5")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                  }
                }

                Text {
                  text: qsTr("Other skills I have:")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  Layout.topMargin: root.sectionsItemTopMargin
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                    weight: Font.Bold
                  }
                }
                Text {
                  text: qsTr("• Cross-Platform Software Development • Cross-Platform Software Deployment • Cross-compilation • Continuous Integration and Continuous Delivery (CI/CD) • Software Design • Software Debugging • Graphical User Interface (GUI) development • Advanced Internal Tools Development • Standard Template Library (STL) • Functional Programming • Object-Oriented Programming (OOP) • Code Refactoring • Concurrent Programming • Software Testing • E-Learning • Web Development • Responsive Web Design • Full-Stack Development • Programming • Software Documentation • Unit Testing • Interpersonal Skills • Problem Solving • Mathematics • Attention to Detail")
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  Layout.alignment: Qt.AlignLeft
                  Layout.maximumWidth: skillsAndToolsLayout.width
                  wrapMode: Text.WordWrap
                  horizontalAlignment: Text.AlignLeft
                  font {
                    pixelSize: root.textFontSize
                  }
                }
              }
            }
          }
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: experienceGridLayout.implicitHeight + root.anchorsMarginsCompensation

            Rectangle {
              anchors.fill: parent
              radius: root.rectangleRadiusSize

              gradient: Gradient {
                GradientStop {
                  position: root.gradientStopPosition1
                  color: root.darkTheme ? "#192b50" : "#e0e7f5"
                }
                GradientStop {
                  position: root.gradientStopPosition2
                  color: root.darkTheme ? "#294675" : "#becbe5"
                }
                GradientStop {
                  position: root.gradientStopPosition3
                  color: root.darkTheme ? "#3f6495" : "#98acd2"
                }
              }

              GridLayout {
                id: experienceGridLayout
                anchors.fill: parent
                anchors.margins: root.anchorsMargins
                columns: width >= root.experienceMobileBreakpoint ? 3 : 1
                columnSpacing: root.sectionsColumnLayoutSpacing
                rowSpacing: root.sectionsColumnLayoutSpacing

                // HEADER
                Text {
                  text: qsTr("Experience")
                  Layout.columnSpan: experienceGridLayout.columns
                  Layout.fillWidth: true
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  font {
                    pixelSize: root.sectionsNameSize
                    weight: Font.ExtraBold
                  }
                }

                // 1. IMAGE
                Item {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.preferredWidth: root.companyIconSize
                  Layout.preferredHeight: root.companyIconSize
                  Layout.alignment: experienceGridLayout.columns === 3 ? Qt.AlignTop | Qt.AlignLeft : Qt.AlignHCenter
                  Image {
                    id: equinoxPaymentsLogo1
                    anchors.fill: parent
                    source: root.darkTheme ? "../../resources/assets/icons/base/dark/squared/equinox-payments.png" : "../../resources/assets/icons/base/light/squared/equinox-payments.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                  }

                  // Rounded-rectangle mask
                  Rectangle {
                    id: equinoxPaymentsLogoMask1
                    anchors.fill: parent
                    radius: root.companyIconCornerRadiusSize
                    visible: false
                    layer.enabled: true
                  }

                  MultiEffect {
                    anchors.fill: equinoxPaymentsLogo1
                    source: equinoxPaymentsLogo1
                    maskEnabled: true
                    maskSource: equinoxPaymentsLogoMask1
                  }
                }

                // 2. EXPERIENCE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Equinox Payments")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("C++ Software Developer")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("• Design and development of new payment engine software features for embedded devices")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• CI / CD pipelines improvements")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Legacy code maintenance")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Hands-on experience in a Linux environment")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Experience working with Docker and Git")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Experience working with C++, Python and Bash")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }

                // 3. DATE
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignRight
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Riga, Latvia")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("02/2026 - 06/2026")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }

                // 1. IMAGE
                Item {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.preferredWidth: root.companyIconSize
                  Layout.preferredHeight: root.companyIconSize
                  Layout.alignment: experienceGridLayout.columns === 3 ? Qt.AlignTop | Qt.AlignLeft : Qt.AlignHCenter
                  Image {
                    id: someCompanyLogo1
                    anchors.fill: parent
                    source: root.darkTheme ? "../../resources/assets/icons/base/dark/squared/some-company.svg" : "../../resources/assets/icons/base/light/squared/some-company.svg"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                  }

                  // Rounded-rectangle mask
                  Rectangle {
                    id: someCompanyLogoMask1
                    anchors.fill: parent
                    radius: root.companyIconCornerRadiusSize
                    visible: false
                    layer.enabled: true
                  }

                  MultiEffect {
                    anchors.fill: someCompanyLogo1
                    source: someCompanyLogo1
                    maskEnabled: true
                    maskSource: someCompanyLogoMask1
                  }
                }

                // 2. EXPERIENCE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Fintech startup")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("Investor")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("• Investor")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Advisor")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• QA")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• UI / UX and security bug researcher")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }

                // 3. DATE
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignRight
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Europe")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("08/2024 - 02/2026")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }

                // 1. IMAGE
                Item {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.preferredWidth: root.companyIconSize
                  Layout.preferredHeight: root.companyIconSize
                  Layout.alignment: experienceGridLayout.columns === 3 ? Qt.AlignTop | Qt.AlignLeft : Qt.AlignHCenter
                  Image {
                    id: sonarworksLogo2
                    anchors.fill: parent
                    source: root.darkTheme ? "../../resources/assets/icons/base/dark/squared/sonarworks.png" : "../../resources/assets/icons/base/light/squared/sonarworks.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                  }

                  // Rounded-rectangle mask
                  Rectangle {
                    id: sonarworksLogoMask2
                    anchors.fill: parent
                    radius: root.companyIconCornerRadiusSize
                    visible: false
                    layer.enabled: true
                  }

                  MultiEffect {
                    anchors.fill: sonarworksLogo2
                    source: sonarworksLogo2
                    maskEnabled: true
                    maskSource: sonarworksLogoMask2
                  }
                }

                // 2. EXPERIENCE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Sonarworks")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("C++ Developer")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("• Cross-platform desktop software development with GUI and maintenance")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Design and development of various advanced partner cross-platform integrations")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Hands-on experience in Windows and macOS environments")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Legacy code maintenance")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Experience working with Git")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Experience working with C++ and Python")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }

                // 3. DATE
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignRight
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Riga, Latvia")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("02/2022 - 07/2024")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }

                // 1. IMAGE
                Item {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.preferredWidth: root.companyIconSize
                  Layout.preferredHeight: root.companyIconSize
                  Layout.alignment: experienceGridLayout.columns === 3 ? Qt.AlignTop | Qt.AlignLeft : Qt.AlignHCenter
                  Image {
                    id: sonarworksLogo1
                    anchors.fill: parent
                    source: root.darkTheme ? "../../resources/assets/icons/base/dark/squared/sonarworks.png" : "../../resources/assets/icons/base/light/squared/sonarworks.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                  }

                  // Rounded-rectangle mask
                  Rectangle {
                    id: sonarworksLogoMask1
                    anchors.fill: parent
                    radius: root.companyIconCornerRadiusSize
                    visible: false
                    layer.enabled: true
                  }

                  MultiEffect {
                    anchors.fill: sonarworksLogo1
                    source: sonarworksLogo1
                    maskEnabled: true
                    maskSource: sonarworksLogoMask1
                  }
                }

                // 2. EXPERIENCE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Sonarworks")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("Junior C++ Developer")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("• Cross-platform desktop software development with GUI and maintenance")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Experience working with Git")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("• Experience working with C++ and Python")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }

                // 3. DATE
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignRight
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Riga, Latvia")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("09/2021 - 10/2021")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
              }
            }
          }
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: educationGridLayout.implicitHeight + root.anchorsMarginsCompensation
            Rectangle {
              radius: root.rectangleRadiusSize
              anchors.fill: parent
              gradient: Gradient {
                GradientStop {
                  position: root.gradientStopPosition1
                  color: root.darkTheme ? "#142f3c" : "#dceff1"
                }
                GradientStop {
                  position: root.gradientStopPosition2
                  color: root.darkTheme ? "#185568" : "#b7dfe3"
                }
                GradientStop {
                  position: root.gradientStopPosition3
                  color: root.darkTheme ? "#23808d" : "#8fc8ce"
                }
              }

              GridLayout {
                id: educationGridLayout
                anchors.fill: parent
                anchors.margins: root.anchorsMargins
                columns: width >= root.experienceMobileBreakpoint ? 3 : 1
                columnSpacing: root.sectionsColumnLayoutSpacing
                rowSpacing: root.sectionsColumnLayoutSpacing

                // HEADER
                Text {
                  text: qsTr("Education")
                  Layout.columnSpan: educationGridLayout.columns
                  Layout.fillWidth: true
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  font {
                    pixelSize: root.sectionsNameSize
                    weight: Font.ExtraBold
                  }
                }

                // 1. IMAGE
                Item {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.preferredWidth: root.companyIconSize
                  Layout.preferredHeight: root.companyIconSize
                  Layout.alignment: educationGridLayout.columns === 3 ? Qt.AlignTop | Qt.AlignLeft : Qt.AlignHCenter
                  Image {
                    id: mgtuLogo1
                    anchors.fill: parent
                    source: root.darkTheme ? "../../resources/assets/icons/base/dark/squared/mgtu.png" : "../../resources/assets/icons/base/light/squared/mgtu.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                  }

                  // Rounded-rectangle mask
                  Rectangle {
                    id: mgtuLogoMask1
                    anchors.fill: parent
                    radius: root.companyIconCornerRadiusSize
                    visible: false
                    layer.enabled: true
                  }

                  MultiEffect {
                    anchors.fill: mgtuLogo1
                    source: mgtuLogo1
                    maskEnabled: true
                    maskSource: mgtuLogoMask1
                  }
                }

                // 2. EDUCATION INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Bauman Moscow State Technical University (Moscow Technical College of Space Instrumentation)")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }

                  Text {
                    text: qsTr("• Diploma, Secondary Vocational Education, Programming technician, Computer systems programming")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }

                // 3. DATE
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignRight
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("Moscow, Russia")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                      weight: Font.Bold
                    }
                  }
                  Text {
                    text: qsTr("09/2017- 06/2021")
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
              }
            }
          }
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: languagesGridLayout.implicitHeight + root.anchorsMarginsCompensation
            Rectangle {
              radius: root.rectangleRadiusSize
              anchors.fill: parent
              gradient: Gradient {
                GradientStop {
                  position: root.gradientStopPosition1
                  color: root.darkTheme ? "#142c3f" : "#dcecf2"
                }
                GradientStop {
                  position: root.gradientStopPosition2
                  color: root.darkTheme ? "#1d4b60" : "#b8d8e3"
                }
                GradientStop {
                  position: root.gradientStopPosition3
                  color: root.darkTheme ? "#286d7b" : "#8fc2cd"
                }
              }

              GridLayout {
                id: languagesGridLayout
                anchors.fill: parent
                anchors.margins: root.anchorsMargins
                columns: width >= root.experienceMobileBreakpoint ? 3 : 1
                columnSpacing: root.sectionsColumnLayoutSpacing
                rowSpacing: root.sectionsColumnLayoutSpacing

                // HEADER
                Text {
                  text: qsTr("Languages")
                  Layout.columnSpan: languagesGridLayout.columns
                  Layout.fillWidth: true
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  font {
                    pixelSize: root.sectionsNameSize
                    weight: Font.ExtraBold
                  }
                }

                // LANGUAGE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("• <b>English</b> - Advanced Level C1")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // LANGUAGE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("• <b>Russian</b> - Native Level C2")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // LANGUAGE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("• <b>Latvian</b> - Beginner Level A2 - B1")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // LANGUAGE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("• <b>German</b> - Beginner Level A1 - A2")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
              }
            }
          }
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: certificationsGridLayout.implicitHeight + root.anchorsMarginsCompensation
            Rectangle {
              radius: root.rectangleRadiusSize
              anchors.fill: parent
              gradient: Gradient {
                GradientStop {
                  position: root.gradientStopPosition1
                  color: root.darkTheme ? "#292344" : "#e8e3f4"
                }
                GradientStop {
                  position: root.gradientStopPosition2
                  color: root.darkTheme ? "#4b3b68" : "#cec3e4"
                }
                GradientStop {
                  position: root.gradientStopPosition3
                  color: root.darkTheme ? "#6b5387" : "#ae9bc9"
                }
              }

              GridLayout {
                id: certificationsGridLayout
                anchors.fill: parent
                anchors.margins: root.anchorsMargins
                columns: 1
                columnSpacing: root.sectionsColumnLayoutSpacing
                rowSpacing: root.sectionsColumnLayoutSpacing

                // HEADER
                Text {
                  text: qsTr("Certifications")
                  Layout.columnSpan: certificationsGridLayout.columns
                  Layout.fillWidth: true
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  font {
                    pixelSize: root.sectionsNameSize
                    weight: Font.ExtraBold
                  }
                }

                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (GitKraken)</b> - Foundations of Git - Certification Course<br><b>URL</b>: <u>learn.\u200Bgitkraken.com\u200B/certificates\u200B/jnqjl6u5gs</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://learn.gitkraken.com/certificates/jnqjl6u5gs");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Qt QML From Beginner to Pro (course by Daniel Gakwaya)</b> - The course has been completed on LearnQt platform<br><b>URL</b>: <u>www.learnqt\u200B.guide</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://www.learnqt.guide");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Qt QML Deploy to Desktop, Mobile and Embedded (course by Daniel Gakwaya)</b> - The course has been completed on LearnQt platform<br><b>URL</b>: <u>www.learnqt\u200B.guide</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://www.learnqt.guide");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Professional Game Development in C++ and Unreal Engine 5 (course by Tom Looman)</b> - The course has been completed on Tom Looman platform<br><b>URL</b>: <u>tomlooman\u200B.com\u200B/courses\u200B/unrealengine-cpp</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://tomlooman.com/courses/unrealengine-cpp");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Educative)</b> - C++ Fundamentals for Professionals (course by Rainer Grimm)<br><b>URL</b>: <u>educative\u200B.io\u200B/verify-certificate\u200B/0g6xMWF\u200BMlJ0QoJq\u200BoOhLQ9L\u200BZ5Bmw4hP</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://educative.io/verify-certificate/0g6xMWFMlJ0QoJqoOhLQ9LZ5Bmw4hP");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Educative)</b> - C++ Standard Library including C++ 14 & C++ 17 (course by Rainer Grimm)<br><b>URL</b>: <u>educative\u200B.io\u200B/verify-certificate\u200B/NxqvGM\u200BS9wqX3nYn\u200BOpFzq8z1\u200BN7omXI2</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://educative.io/verify-certificate/NxqvGMS9wqX3nYnOpFzq8z1N7omXI2");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Educative)</b> - Generic Programming Templates in C++ (course by Rainer Grimm)<br><b>URL</b>: <u>educative\u200B.io\u200B/verify-certificate\u200B/lOn30B\u200BIkgr2RVO\u200Bj10uVXNVz\u200BBlPGmFM</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://educative.io/verify-certificate/lOn30BIkgr2RVOj10uVXNVzBlPGmFM");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Educative)</b> - Embedded Programming with Modern C++ (course by Rainer Grimm)<br><b>URL</b>: <u>educative\u200B.io\u200B/verify-certificate\u200B/j2l3Bz\u200BfAXX2lVBw\u200B3MFjyYjAP\u200BJvWOFA</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://educative.io/verify-certificate/j2l3BzfAXX2lVBw3MFjyYjAPJvWOFA");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Educative)</b> - Modern C++ Concurrency: Get the most out of any machine (course by Rainer Grimm)<br><b>URL</b>: <u>educative\u200B.io\u200B/verify-certificate\u200B/585DM\u200B2tRAQOYmr\u200BBKgSNR9N\u200B6vAgzBFq</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://educative.io/verify-certificate/585DM2tRAQOYmrBKgSNR9N6vAgzBFq");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Educative)</b> - The All-in-One Guide to C++20 (course by Rainer Grimm)<br><b>URL</b>: <u>educative\u200B.io\u200B/verify-certificate\u200B/Y6GKZ1\u200Bijon9YGVP\u200BOkU3Jw3E\u200B7450DsJ</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://educative.io/verify-certificate/Y6GKZ1ijon9YGVPOkU3Jw3E7450DsJ");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Educative)</b> - Master Software Design Patterns and Architecture in C++ (course by Rainer Grimm)<br><b>URL</b>: <u>educative\u200B.io\u200B/verify-certificate\u200B/0g6xM\u200BWFMM9vBY5\u200BXoMFLQ9LZ\u200B5Bmw4hP</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://educative.io/verify-certificate/0g6xMWFMM9vBY5XoMFLQ9LZ5Bmw4hP");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Qt C++ Widgets Intermediate: Build Feature-Rich UIs (course by Daniel Gakwaya)<br><b>URL</b>: <u>ude\u200B.my\u200B/UC\u200B-d8d6246f-d893\u200B-40df-9588\u200B-edcb3ebb9e44</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-d8d6246f-d893-40df-9588-edcb3ebb9e44");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - C++23 Fundamentals with Projects & Algorithms (course by Daniel Gakwaya)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-b8da4ca1-3977\u200B-4678-95d8\u200B-ce42cba3da9e</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-b8da4ca1-3977-4678-95d8-ce42cba3da9e");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - The C++20 Masterclass : From Fundamentals to Advanced (course by Daniel Gakwaya)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-4e0fefda-3b01\u200B-4f37-86df\u200B-ba7e8eed275c</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-4e0fefda-3b01-4f37-86df-ba7e8eed275c");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Complete CMake Project Management [2023] (course by Hristo Iliev)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-7eb1bafe-c525\u200B-4770-8a2f\u200B-36338b0ab894</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-7eb1bafe-c525-4770-8a2f-36338b0ab894");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - CMake, Tests and Tooling for C/C++ Projects [2024 Edition] (course by Jan Schaffranek)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-0fe60ba0-a763\u200B-4f1c-8299\u200B-d82a7cf19d03</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-0fe60ba0-a763-4f1c-8299-d82a7cf19d03");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Modern C++ Concurrency in Depth (C++17/20) (course by Kasun Liyanage)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-d23e3535-8b31\u200B-4a05-8876\u200B-45144df57edc</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-d23e3535-8b31-4a05-8876-45144df57edc");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Python Hands-On 46 Hours, 210 Exercises, 5 Projects, 2 Exams (course by Musa Arda)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-a1592a03-b26a\u200B-48ea-a6d9\u200B-0e8c1d1ef373</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-a1592a03-b26a-48ea-a6d9-0e8c1d1ef373");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Python: Coding Guidelines, Tools, Tests and Packages [2024] (course by Jan Schaffranek)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-24051b0a-f479\u200B-472d-a373\u200B-621522395162</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-24051b0a-f479-472d-a373-621522395162");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Intermediate Python: Memory, Decorator, Async, Cython & more (course by Jan Schaffranek)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-dd44397f-102a\u200B-41c7-b70a\u200B-bc437df3cd1f</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-dd44397f-102a-41c7-b70a-bc437df3cd1f");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Quick Start in modern Python - Coming from another language (course by Jan Schaffranek)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-6ecc28b6-7c26\u200B-4b22-8d48\u200B-ace5b112f671</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-6ecc28b6-7c26-4b22-8d48-ace5b112f671");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Git Mastery: Beginner to Expert with GitHub & GitLab (course by Mike Kilic)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-d1bb46b3-f209\u200B-4b20-8888\u200B-f41f81659653</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-d1bb46b3-f209-4b20-8888-f41f81659653");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Qt For Python (PySide6) GUI For Beginners : The Fundamentals (course by Daniel Gakwaya)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-69898887-e2a6\u200B-490c-815b\u200B-a8becd8f564c</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-69898887-e2a6-490c-815b-a8becd8f564c");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Qt 6 C++ GUI Development for Beginners : The Fundamentals (course by Daniel Gakwaya)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-2d082243-d6a6\u200B-44c8-ba2e\u200B-b36748d932f9</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-2d082243-d6a6-44c8-ba2e-b36748d932f9");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Qt 6 Core Beginners with C++ (course by Bryan Cairns)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-7b742acd-2b2c\u200B-45d4-b49b\u200B-64794d61b52a</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-7b742acd-2b2c-45d4-b49b-64794d61b52a");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Qt 6 Core Intermediate with C++ (course by Bryan Cairns)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-43d8004a-a5a3\u200B-40e6-91fa\u200B-21c951166be0</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-43d8004a-a5a3-40e6-91fa-21c951166be0");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Qt 6 Core Advanced with C++ (course by Bryan Cairns)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-33be8673-770b\u200B-46a9-ae8e\u200B-dc0830a0d803</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-33be8673-770b-46a9-ae8e-dc0830a0d803");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Node.js, Express, MongoDB & More: The Complete Bootcamp 2023 (course by Jonas Schmedtmann)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-05115e60-951b\u200B-4253-9c2c\u200B-a0e6d3b518e8</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-05115e60-951b-4253-9c2c-a0e6d3b518e8");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - The Complete JavaScript Course 2023: From Zero to Expert! (course by Jonas Schmedtmann)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-490f9a1c-3e51\u200B-415c-9af0\u200B-6341b7a9022c</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-490f9a1c-3e51-415c-9af0-6341b7a9022c");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Advanced CSS and Sass: Flexbox, Grid, Animations and More! (course by Jonas Schmedtmann)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-e8916020-1341\u200B-4d7c-95a4\u200B-de5aee5ceadd</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-e8916020-1341-4d7c-95a4-de5aee5ceadd");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Build Responsive Real-World Websites with HTML and CSS (course by Jonas Schmedtmann)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-6e24e050-ebfc\u200B-491d-90e5\u200B-45d7e2a06725</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-6e24e050-ebfc-491d-90e5-45d7e2a06725");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Udemy)</b> - Crash Course: Build a Full-Stack Web App in a Weekend! (course by Jonas Schmedtmann)<br><b>URL</b>: <u>ude.my\u200B/UC\u200B-a0f64036-cafe\u200B-4157-bd73\u200B-47fd383fb569</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://ude.my/UC-a0f64036-cafe-4157-bd73-47fd383fb569");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Coursera)</b> - Learn English: Intermediate Grammar Specialization (University of California, Irvine)<br><b>URL</b>: <u>coursera\u200B.org\u200B/account\u200B/accomplishments\u200B/specialization\u200B/K3B057VKVO5U</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://coursera.org/account/accomplishments/specialization/K3B057VKVO5U");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Coursera)</b> - Adjectives and Adjective Clauses (University of California, Irvine)<br><b>URL</b>: <u>coursera\u200B.org\u200B/account\u200B/accomplishments\u200B/verify\u200B/876G4US2FD5N</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://coursera.org/account/accomplishments/verify/876G4US2FD5N");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Coursera)</b> - Intermediate Grammar Project (University of California, Irvine)<br><b>URL</b>: <u>coursera\u200B.org\u200B/account\u200B/accomplishments\u200B/verify\u200B/JRT0NLJG06S6</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://coursera.org/account/accomplishments/verify/JRT0NLJG06S6");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Coursera)</b> - Perfect Tenses and Modals (University of California, Irvine)<br><b>URL</b>: <u>coursera\u200B.org\u200B/account\u200B/accomplishments\u200B/verify\u200B/UN26QUN5ZGVS</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://coursera.org/account/accomplishments/verify/UN26QUN5ZGVS");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Coursera)</b> - Tricky English Grammar (University of California, Irvine)<br><b>URL</b>: <u>coursera\u200B.org\u200B/account\u200B/accomplishments\u200B/verify\u200B/WF43VKO6JQCA</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://coursera.org/account/accomplishments/verify/WF43VKO6JQCA");
                      }
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Humboldt-Institut e. V.)</b> - German language level A1")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (Humboldt-Institut e. V.)</b> - German language level A2")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (State Education Development Agency)</b> - Latvian language level A1")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (State Education Development Agency)</b> - Latvian language level A2")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (International House World Organisation)</b> - English language level B2")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // CERTIFICATE INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Certificate (International House World Organisation)</b> - English language level C1")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
              }
            }
          }
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: portfolioProjectsGridLayout.implicitHeight + root.anchorsMarginsCompensation
            Rectangle {
              radius: root.rectangleRadiusSize
              anchors.fill: parent
              gradient: Gradient {
                GradientStop {
                  position: root.gradientStopPosition1
                  color: root.darkTheme ? "#182f3a" : "#dcebe7"
                }
                GradientStop {
                  position: root.gradientStopPosition2
                  color: root.darkTheme ? "#24534e" : "#b9d8cf"
                }
                GradientStop {
                  position: root.gradientStopPosition3
                  color: root.darkTheme ? "#347666" : "#91c2b1"
                }
              }

              GridLayout {
                id: portfolioProjectsGridLayout
                anchors.fill: parent
                anchors.margins: root.anchorsMargins
                columns: 1
                columnSpacing: root.sectionsColumnLayoutSpacing
                rowSpacing: root.sectionsColumnLayoutSpacing

                // HEADER
                Text {
                  text: qsTr("Portfolio Projects")
                  Layout.columnSpan: portfolioProjectsGridLayout.columns
                  Layout.fillWidth: true
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  color: root.darkTheme ? "#F4FBFF" : "#123044"
                  font {
                    pixelSize: root.sectionsNameSize
                    weight: Font.ExtraBold
                  }
                }

                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>my-qt-qml-pro-projects-showcase</b><br><b>URL</b>: <u>github\u200B.com\u200B/xyzdelete\u200B/my\u200B-qt\u200B-qml\u200B-pro\u200B-projects\u200B-showcase</u>")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://github.com/xyzdelete/my-qt-qml-pro-projects-showcase");
                      }
                    }
                  }
                  Text {
                    text: qsTr("<b>Learning C++, Qt, Qt Quick, QML. Projects showcase.</b>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Object-Oriented Programming (OOP) • Cross-platform software development • Qt Creator • Windows • Problem Solving • Artificial Intelligence (AI) • Software Design • E-Learning • Standard Template Library (STL) • QML • Functional Programming • Qt • GitKraken Legendary Git Tools | GitKraken • Bash • English • Code Refactoring • Graphical User Interface (GUI) • CPack • CMake • msvc • macOS • C++ Programming Language • iOS • Docker • Visual Studio Code • Git • cross-compilation • Qt Quick • Android • Linux • Cross-platform software deployment • WebAssembly • vcpkg • Continuous Integration and Continuous Delivery (CI/CD) • Programming • Software Testing • Software Debugging • Attention to Detail")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>qt-shapes-drawing-app</b><br><b>URL</b>: <u>github\u200B.com\u200B/xyzdelete\u200B/qt\u200B-shapes\u200B-drawing\u200B-app</u>")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://github.com/xyzdelete/qt-shapes-drawing-app");
                      }
                    }
                  }
                  Text {
                    text: qsTr("<b>App draws 4 figures: Square, Rectangle, Triangle, Circle. Toolbar: modify (select, move, rotate, clone, erase), draw each shape. File menu: New, Load, Save, Save as, Exit.</b>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Object-Oriented Programming (OOP) • Qt Creator • Windows • Problem Solving • Software Design • E-Learning • Standard Template Library (STL) • Functional Programming • Qt • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • Graphical User Interface (GUI) • CMake • msvc • C++ Programming Language • Visual Studio Code • Git • Programming • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Diploma Project</b>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr(`<b>Software development project. Final Qualification Paper (Diploma Project). "Developing Software for Downloading, Reading, Writing, Archiving, Encryption and Decryption Files operated by a Graphical User Interface".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Object-Oriented Programming (OOP) • Qt Creator • Windows • Problem Solving • Visual Studio • Software Design • E-Learning • Standard Template Library (STL) • QML • Qt • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • Graphical User Interface (GUI) • CMake • msvc • C++ Programming Language • Visual Studio Code • Git • Qt Quick • Programming • Microsoft Office • Software Documentation • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>SEDZUGT</b>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr(`<b>Software development project "Simple Encryption Decryption Zip Unzip GUI Tool".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Object-Oriented Programming (OOP) • Qt Creator • Windows • Problem Solving • Visual Studio • Software Design • E-Learning • Standard Template Library (STL) • QML • Functional Programming • Qt • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • Graphical User Interface (GUI) • CMake • msvc • C++ Programming Language • Visual Studio Code • Git • Qt Quick • Programming • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Omnifood</b><br><b>URL</b>: <u>omnifood\u200B-arturs\u200B-anikins\u200B.netlify\u200B.app</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://omnifood-arturs-anikins.netlify.app");
                      }
                    }
                  }
                  Text {
                    text: qsTr(`<b>Web development project "Omnifood". It was built by Arturs Anikins during completion of the online course by Jonas Schmedtmann "Build Responsive Real-World Websites with HTML and CSS".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Windows • Problem Solving • Software Design • E-Learning • Responsive Web Design • Web Development • Cascading Style Sheets (CSS) • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • HTML • Visual Studio Code • Git • Programming • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Natours</b><br><b>URL</b>: <u>natours\u200B-arturs\u200B-anikins\u200B.netlify\u200B.app</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://natours-arturs-anikins.netlify.app");
                      }
                    }
                  }
                  Text {
                    text: qsTr(`<b>Web development project "Natours". It was built by Arturs Anikins during completion of the online course by Jonas Schmedtmann "Advanced CSS and Sass: Flexbox, Grid, Animations and More!".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Windows • Problem Solving • Software Design • E-Learning • Responsive Web Design • Web Development • Cascading Style Sheets (CSS) • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • HTML • Visual Studio Code • Git • Programming • SASS • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Nexter</b><br><b>URL</b>: <u>nexter\u200B-arturs\u200B-anikins\u200B.netlify\u200B.app</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://nexter-arturs-anikins.netlify.app");
                      }
                    }
                  }
                  Text {
                    text: qsTr(`<b>Web development project "Nexter". It was built by Arturs Anikins during completion of the online course by Jonas Schmedtmann "Advanced CSS and Sass: Flexbox, Grid, Animations and More!".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Windows • Problem Solving • Software Design • E-Learning • Responsive Web Design • Web Development • Cascading Style Sheets (CSS) • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • HTML • Visual Studio Code • Git • Programming • SASS • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Trillo</b><br><b>URL</b>: <u>trillo\u200B-arturs\u200B-anikins\u200B.netlify\u200B.app</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://trillo-arturs-anikins.netlify.app");
                      }
                    }
                  }
                  Text {
                    text: qsTr(`<b>Web development project "Trillo". It was built by Arturs Anikins during completion of the online course by Jonas Schmedtmann "Advanced CSS and Sass: Flexbox, Grid, Animations and More!".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Windows • Problem Solving • Software Design • E-Learning • Responsive Web Design • Web Development • Cascading Style Sheets (CSS) • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • HTML • Visual Studio Code • Git • Programming • SASS • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Bankist</b><br><b>URL</b>: <u>bankist\u200B-arturs\u200B-anikins\u200B.netlify\u200B.app</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://bankist-arturs-anikins.netlify.app");
                      }
                    }
                  }
                  Text {
                    text: qsTr(`<b>Web development project "Bankist". It was built by Arturs Anikins during completion of the online course by Jonas Schmedtmann "The Complete JavaScript Course 2023: From Zero to Expert!".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Windows • Problem Solving • Software Design • E-Learning • Web Development • Cascading Style Sheets (CSS) • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • HTML • JavaScript • Visual Studio Code • Git • Programming • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Forkify</b><br><b>URL</b>: <u>forkify\u200B-arturs\u200B-anikins\u200B.netlify\u200B.app</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://forkify-arturs-anikins.netlify.app");
                      }
                    }
                  }
                  Text {
                    text: qsTr(`<b>Web development project "Forkify". It was built by Arturs Anikins during completion of the online course by Jonas Schmedtmann "The Complete JavaScript Course 2023: From Zero to Expert!".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Windows • Problem Solving • Software Design • E-Learning • Web Development • Cascading Style Sheets (CSS) • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • HTML • JavaScript • Visual Studio Code • Git • Programming • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Pig Game</b><br><b>URL</b>: <u>pig\u200B-game\u200B-arturs\u200B-anikins\u200B.netlify\u200B.app</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://pig-game-arturs-anikins.netlify.app");
                      }
                    }
                  }
                  Text {
                    text: qsTr(`<b>Web development project "Pig Game". It was built by Arturs Anikins during completion of the online course by Jonas Schmedtmann "The Complete JavaScript Course 2023: From Zero to Expert!".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Windows • Problem Solving • Software Design • E-Learning • Web Development • Cascading Style Sheets (CSS) • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • HTML • JavaScript • Visual Studio Code • Git • Programming • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
                // PROJECT INFORMATION
                ColumnLayout {
                  Layout.topMargin: root.sectionsItemTopMargin
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                  spacing: root.sectionsColumnLayoutSpacing
                  Text {
                    text: qsTr("<b>Guess My Number</b><br><b>URL</b>: <u>guess\u200B-my\u200B-number\u200B-arturs\u200B-anikins\u200B.netlify\u200B.app</u>")
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        Qt.openUrlExternally("https://guess-my-number-arturs-anikins.netlify.app");
                      }
                    }
                  }
                  Text {
                    text: qsTr(`<b>Web development project "Guess My Number". It was built by Arturs Anikins during completion of the online course by Jonas Schmedtmann "The Complete JavaScript Course 2023: From Zero to Expert!".</b>`)
                    textFormat: Text.RichText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                  Text {
                    text: qsTr("Skills: • Windows • Problem Solving • Software Design • E-Learning • Web Development • Cascading Style Sheets (CSS) • GitKraken Legendary Git Tools | GitKraken • English • Code Refactoring • HTML • JavaScript • Visual Studio Code • Git • Programming • Software Testing • Software Debugging")
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    color: root.darkTheme ? "#F4FBFF" : "#123044"
                    font {
                      pixelSize: root.textFontSize
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
