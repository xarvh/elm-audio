
if (typeof require === 'undefined') {
  // Browser

  var elmApp = Elm.Main.fullscreen();
  elmApp.ports.sendTestStatusToBackendPort.subscribe(function () {});

} else {
  // Electron

  var elmApp = module.exports.Main.fullscreen();

  var ipcRenderer = require('electron').ipcRenderer;

  elmApp.ports.sendTestStatusToBackendPort.subscribe(function (tuple) {
    ipcRenderer.send('testInfo', { name: tuple[0], status: tuple[1], pendingCount: tuple[2] });
  });

  window.onerror = function (message, sourceFile, lineNumber) {
    ipcRenderer.send('windowError', { message: message, sourceFile: sourceFile, lineNumber: lineNumber });
  };
}
