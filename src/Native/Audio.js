Elm.Native.Audio = {};
Elm.Native.Audio.make = function make(elm) {

  elm.Native = elm.Native || {};
  elm.Native.Audio = elm.Native.Audio || {};
  if (elm.Native.Audio.values) {
    return elm.Native.Audio.values;
  }

  var Task = Elm.Native.Task.make(elm);


  function loadSound(source) {
    return Task.asyncFunction(function (callback) {
      var audio = new Audio();
      audio.preload = 'auto';
      audio.oncanplaythrough = function () { callback(Task.succeed({ ctor: 'Sound', audio: audio })); };
      audio.onerror = function (err) { callback(Task.fail({ ctor: 'Error', message: err })); };
      audio.src = source;
    });
  }


  function playSound(options, sound) {
    return Task.asyncFunction(function (callback) {
      sound.audio.volume = options.volume;
      sound.audio.loop = options.loop;
      if (options.startAt.ctor == 'Just') { sound.audio.currentTime = options.startAt._0; }
      sound.audio.onended = function () { callback(Task.succeed()); };
      sound.audio.play();
    });
  }


  function stopSound(sound) {
    return Task.asyncFunction(function (callback) {
      sound.audio.pause();
      callback(Task.succeed());
    });
  }


  return elm.Native.Audio.values = {
    loadSound: loadSound,
    playSound: F2(playSound),
    stopSound: stopSound,
  };
};
