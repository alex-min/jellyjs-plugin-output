// Generated by CoffeeScript 1.6.2
var async, fs, getOutputContentFromFile, getOutputFilenameFromFile, mkdirIfNotExist, mkdirp, outputFile, path;

mkdirp = require('mkdirp');

fs = require('fs');

path = require('path');

async = require('async');

mkdirIfNotExist = function(dir, cb) {
  return fs.stat(dir, function(err, stat) {
    if (err && err.code !== 'ENOENT') {
      cb(err);
      cb = function() {};
      return;
    }
    if (!err) {
      if (stat.isDirectory()) {
        cb();
        cb = function() {};
        return;
      }
      if (stat.isFile()) {
        cb(new Error("Unable to output to the folder '" + dir + "', a file with the same name already exist"));
        cb = function() {};
        return;
      }
    }
    return mkdirp(dir, function(err) {
      return cb(err);
    });
  });
};

getOutputContentFromFile = function(file, options) {
  var content, currentContent, ext, _i, _len, _ref;

  currentContent = file.getCurrentContent();
  if (currentContent === null || typeof currentContent.content === 'undefined' || currentContent.content === null) {
    return null;
  }
  if (options.searchForLastGeneratedExtension !== true) {
    return currentContent;
  }
  if (typeof options.allowedGeneratedExtensions === 'undefined' || options.allowedGeneratedExtensions === null) {
    return currentContent;
  }
  _ref = options.allowedGeneratedExtensions;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    ext = _ref[_i];
    content = file.getLastContentOfExtension(ext);
    if (content !== null && typeof content.content !== 'undefined' && content.content !== null) {
      return content;
    }
  }
  return null;
};

getOutputFilenameFromFile = function(file, content, options, cb) {
  var extension, filenameCore;

  if (options.useGeneratedExtensionsAsOutput !== true) {
    return file.getId();
  }
  filenameCore = path.basename(file.getId(), path.extname(file.getId()));
  extension = content.extension || file.getLastOfProperty('extension') || '';
  return "" + filenameCore + "." + extension;
};

outputFile = function(file, jelly, options, cb) {
  var fileList, prevFileList, self;

  self = this;
  cb = cb || function() {};
  fileList = [];
  prevFileList = this.getSharedObjectManager().getObject('output', 'file-list');
  return async.each(options.outputDirectoryList, function(dir, cb) {
    dir = "" + (jelly.getRootDirectory()) + "/" + dir;
    return mkdirIfNotExist(dir, function(err) {
      var content, filename;

      content = null;
      filename = null;
      return async.series([
        function(cb) {
          content = getOutputContentFromFile(file, options);
          if (content === null) {
            self.getLogger().warn("Unable to find a content to output for file " + (file.getId()));
          }
          cb();
          return cb = function() {};
        }, function(cb) {
          if (content === null) {
            cb();
            cb = function() {};
            return;
          }
          filename = getOutputFilenameFromFile(file, content, options);
          return cb();
        }, function(cb) {
          var endFilename;

          endFilename = "" + dir + "/" + filename;
          return fs.writeFile(endFilename, content.content.toString(), function(err) {
            fileList.push({
              absoluteFilename: endFilename,
              filename: filename,
              obj: file
            });
            return cb(err);
          });
        }
      ], cb);
    });
  }, function(err) {
    if (err != null) {
      cb(err);
      cb = function() {};
      return;
    }
    prevFileList.updateContent(fileList);
    return cb();
  });
};

/*
      async.each(params.pluginParameters.output.outputDirectoryList, (dir, cb) ->
        dir = "#{jelly.getRootDirectory()}/#{dir}"
        mkdirIfNotExist(dir, (err) ->
          if err
            cb(err); cb = ->
            return
          console.log path.extname(obj.getId()).replace('.','')
          if typeof options.allowedInputExtensions != 'object' \
            || options.allowedInputExtensions.indexOf(path.extname(obj.getId()).replace('.','')) != -1 
              self.getLogger().info("Writing file '#{dir}/#{obj.getId()}'")
              fs.writeFile("#{dir}/#{obj.getId()}", obj.getCurrentContent().content.toString(), (err) ->
                cb(err)
              )
          else
            cb()
        )
        ;
      , cb)
*/


module.exports = {
  load: function(cb) {
    this.getSharedObjectManager().registerObject('output', 'file-list', []);
    return cb();
  },
  oncall: function(obj, params, cb) {
    var jelly, options, self, _base, _base1, _ref, _ref1, _ref2;

    self = this;
    if ((_ref = params.pluginParameters) == null) {
      params.pluginParameters = {};
    }
    if ((_ref1 = (_base = params.pluginParameters).output) == null) {
      _base.output = {};
    }
    if ((_ref2 = (_base1 = params.pluginParameters.output).outputDirectoryList) == null) {
      _base1.outputDirectoryList = [];
    }
    options = params.pluginParameters.output;
    jelly = this.getParentOfClass('Jelly');
    if (obj.File === true) {
      outputFile.call(this, obj, jelly, options, cb);
      return;
    }
    cb();
    return cb = function() {};
  },
  unload: function(cb) {
    return cb();
  }
};
