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
      if (typeof Audio === 'undefined') {
        return callback(Task.fail('The browser does not support HTML5 Audio'));
      }

      var audio = new Audio();

      function oncanplaythrough() {
        var o = { ctor: 'Sound', src: source };
        Object.defineProperty(o, 'audio', { value: audio });
        callback(Task.succeed(o));
      };

      function onerror(/* event */) {
        callback(Task.fail('Unable to load ' + source));
      };

      audio.addEventListener('canplaythrough', oncanplaythrough, false);
      audio.addEventListener('error', onerror, false);
      audio.preload = 'auto';
      audio.src = source;
      audio.load();
    });
  }


  function playSound(options, sound) {
    return Task.asyncFunction(function (callback) {
      var audio = sound.audio;

      audio.volume = options.volume;
      audio.loop = options.loop;
      if (options.startAt.ctor === 'Just') { audio.currentTime = options.startAt._0; }

      function onended() {
        callback(Task.succeed());
      };

      audio.addEventListener('ended', onended, false);
      audio.play();
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
