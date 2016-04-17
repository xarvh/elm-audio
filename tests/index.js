var elmApp = Elm.Main.fullscreen();

if (typeof require !== 'undefined') {

  var ipc = require('electron').ipcRenderer;

  window.onerror = function (errorMessage, sourceFile, lineNumber) {
    ipc.send('stuff', JSON.stringify([errorMessage, sourceFile, lineNumber]));
  };
}
