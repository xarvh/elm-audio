var _xarvh$elm_audio$Native_Audio = function() {


  var Task = _elm_lang$core$Native_Scheduler;


  function loadSound(source) {
    return Task.nativeBinding(function (callback) {

      if (typeof Audio === 'undefined') {
        return callback(Task.fail('The browser does not support HTML5 Audio'));
      }

      var audio = new Audio();
      audio.preload = 'auto';

      function oncanplaythrough() {
        // `canplaythrough` triggers also when audio.currentTime is assigned
        audio.removeEventListener('canplaythrough', oncanplaythrough, false);

        var elmSound = { ctor: 'Sound', src: source };

        // define audio as non-enumerable property to allow comparison and stringification
        Object.defineProperty(elmSound, 'audio', { value: audio });

        callback(Task.succeed(elmSound));
      };

      function onerror(/* event */) {
        callback(Task.fail('Unable to load ' + source));
      };

      audio.addEventListener('canplaythrough', oncanplaythrough, false);
      audio.addEventListener('error', onerror, false);
      audio.src = source;
      audio.load();
    });
  }


  function playSound(options, sound) {
    return Task.nativeBinding(function (callback) {
      var audio = sound.audio;

      audio.loop = options.loop;

      if (options.volume < 0 || options.volume > 1) {
        return callback(Task.fail('volume should be within 0 and 1, but is ' + options.volume));
      }
      audio.volume = options.volume;

      if (options.startAt.ctor === 'Just') {
        var startAt = options.startAt._0;
        if (!(startAt >= 0) || !isFinite(startAt)) {
          return callback(Task.fail('startAt should be finite and positive, but is ' + startAt));
        }
        audio.currentTime = options.startAt._0;
      }

      function onended() {
        callback(Task.succeed());
      };

      audio.addEventListener('ended', onended, false);
      audio.play();
    });
  }


  function stopSound(sound) {
    return Task.nativeBinding(function (callback) {
      sound.audio.pause();
      callback(Task.succeed());
    });
  }


  return {
    loadSound: loadSound,
    playSound: F2(playSound),
    stopSound: stopSound,
  };
}();
