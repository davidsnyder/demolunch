//Carlos Correa Summer 2011
//new Timer(#countdown,new Date("date string"));
function Timer(selector,end_datetime) {
  this.selector = selector;
  this.init(end_datetime);
}

Timer.prototype = {
  ms_in_s: 1000,
  init: function(end_datetime) {
    var self = this;
    this.end = end_datetime;
    this.intervalId = setInterval(function() {
                                    self.setView();
                                  }, this.ms_in_s);
  },
  setView: function() {
    var diff = this.end - +new Date;
    if (diff < this.ms_in_s) {
      clearInterval(this.intervalId);
      return;
    }
    $(this.selector).text(this.prettyFormat(diff));
  },
  prettyFormat: function(diff) {
    var type;
    diff /= this.ms_in_s;
    var minute = Math.floor(diff / 60); // ceil if only minute -- floor if including seconds
    var second = Math.floor(diff % 60);

    var strsecond = (second < 10 && minute > 0 ? '0' : '') + second;

    if (minute > 0) {
      return minute + ':' + strsecond + ' minutes';
    } else {
      return strsecond;
    }
  }
};
