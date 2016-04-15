var app = require('app');
var ipc = require('electron').ipcMain;
var BrowserWindow = require('browser-window');
var path = require('path');

app.on('ready', function () {

  var browserWindow = new BrowserWindow();
  browserWindow.loadURL('file://' + path.join(__dirname, 'index.html'));
  browserWindow.openDevTools();

  ipc.on('stuff', function (e, v) {
    console.log('server ------', v);
  });
});
