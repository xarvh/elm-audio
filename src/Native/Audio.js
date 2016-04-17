var _xarvh$elm_audio$Native_Audio = function() {

Elm.Native.Audio = {};
Elm.Native.Audio.make = function make(elm) {

  var scheduler = _elm_lang$core$Native_Scheduler

  function loadSound(source) {
    return scheduler.nativeBinding(function(callback){

      if (typeof Audio === 'undefined') {
        return callback(scheduler.fail('The browser does not support HTML5 Audio'));
      }

      var audio = new Audio();

      function oncanplaythrough() {
        var o = { ctor: 'Sound', src: source };
        Object.defineProperty(o, 'audio', { value: audio });
        callback(scheduler.succeed(o));
      };

      function onerror(/* event */) {
        callback(scheduler.fail('Unable to load ' + source));
      };

      audio.addEventListener('canplaythrough', oncanplaythrough, false);
      audio.addEventListener('error', onerror, false);
      audio.preload = 'auto';
      audio.src = source;
      audio.load();
    });
  }


  function playSound(options, sound) {
    return scheduler.nativeBinding(function (callback) {
      var audio = sound.audio;

      audio.volume = options.volume;
      audio.loop = options.loop;
      if (options.startAt.ctor === 'Just') { audio.currentTime = options.startAt._0; }

      function onended() {
        callback(scheduler.succeed());
      };

      audio.addEventListener('ended', onended, false);
      audio.play();
    });
  }


  function stopSound(sound) {
    return scheduler.nativeBinding(function (callback) {
      sound.audio.pause();
      callback(scheduler.succeed());
    });
  }


  return elm.Native.Audio.values = {
    loadSound: loadSound,
    playSound: F2(playSound),
    stopSound: stopSound,
  };
};
