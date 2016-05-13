const {app, BrowserWindow, ipcMain} = require('electron');


// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let win;


app.on('ready', function () {
  win = new BrowserWindow();
  win.loadURL('file://' + __dirname + '/index.html');
  win.webContents.openDevTools();
  win.on('closed', () => { win = null; });


  var windowErrors = [];

  ipcMain.on('windowError', function (event, error) {
    windowErrors.push(error);
    console.error('window.onerror: ' + error.sourceFile + ':' + error.lineNumber + '| "' + error.message + '"');
  });


  var testsByName = {};

  ipcMain.on('testInfo', function (event, info) {
    testsByName[info.name] = info.status;

    switch (info.status) {
      case 'Pending': console.info('Test: ' + info.name); break;
      case 'Successful': console.info('-> Pass'); break;
      default: console.error('!> ', info.status); break;
    }

    if (info.pendingCount == 0) { allDone(); }
  });


  function allDone() {

    var allSuccessful = true;
    for (var name in testsByName) {
      if (testsByName[name] !== 'Successful') { allSuccessful = false; }
    }

    var exitCode = allSuccessful && !windowErrors.length ? 0 : -1;

    process.exit(exitCode);
  }
});
