// Generated by CoffeeScript 1.6.2
(function() {
  var colors, fileData, fs, moment;

  colors = require('colors');

  fs = require('fs');

  moment = require('moment');

  fileData = "exports.change = (callback) ->\n  return callback []";

  exports.help = function() {
    console.log("example:");
    return console.log("  cake -n [file_name] db:migrate:new");
  };

  exports.main = function(options) {
    var fileName;

    if (options.name != null) {
      fileName = moment().format('YYYYMMDDHHmmss') + ("_" + options.name + ".coffee");
      return fs.writeFile("db/migrate/" + fileName, fileData, function(err) {
        if (err) {
          return console.log(err.toString().red);
        }
        return console.log(("file " + fileName + " created").green);
      });
    } else {
      console.log('missing file name'.red);
      return this.help();
    }
  };

}).call(this);
