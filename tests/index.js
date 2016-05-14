var isElectron = typeof require !== 'undefined';


var elmApp = (isElectron ? module.exports : Elm).Main.fullscreen();


if (!isElectron) {
  elmApp.ports.sendUpdateToBackendPort.subscribe(function (tuple) { console.info(tuple);});

} else {
  var ipcRenderer = require('electron').ipcRenderer;

  elmApp.ports.sendUpdateToBackendPort.subscribe(function (tuple) {
    ipcRenderer.send('update', { name: tuple[0], status: tuple[1], pendingCount: tuple[2] });
  });

  window.onerror = function (message, sourceFile, lineNumber) {
    elmApp.ports.windowOnErrorPort.send(sourceFile + ':' + lineNumber + '| ' + message);
  };

  setTimeout(function () {elmApp.ports.automatedRunPort.send(''); }, 100);
}
