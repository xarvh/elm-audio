var ipc = require('electron').ipcRenderer;
var elmApp = Elm.fullscreen(Elm.Main, {});

window.onerror = function (errorMessage, sourceFile, lineNumber) {
  ipc.send('stuff', JSON.stringify([errorMessage, sourceFile, lineNumber]));
};
