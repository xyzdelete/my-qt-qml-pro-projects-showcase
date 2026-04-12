import QtQuick
// import SignalHandlers
// import SignalParameters
// import PropertyChangeSignals
// import Connections
// import AttachedSignalHandlers
// import CustomSignals
// import ConnectSignalToMethod
// import ConnectSignalToSignal
import SignalsAcrossComponents

Window{
  width: 640
  height: 480
  visible: true
  title: qsTr("Signals And Slots")

  // SignalHandler{}
  
  // SignalParameters{}

  // PropertyChangeSignals{}
  
  // Connections{}

  // AttachedSignalHandlers{}

  // CustomSignals{}

  // ConnectSignalToMethod{}

  // ConnectSignalToSignal{}

  SignalsAcrossComponents{
    width: parent.width
    height: parent.height
  }

}
