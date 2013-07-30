mkdirp = require('mkdirp')
fs = require('fs')
async = require('async')

mkdirIfNotExist= (dir, cb) ->
  fs.stat(dir, (err, stat) ->
    if err && err.code != 'ENOENT'
      cb(err); cb = ->
      return
    if !err
      if stat.isDirectory()
        cb(); cb = ->
        return
      if stat.isFile()
        cb(new Error("Unable to output to the folder '#{dir}', a file with the same name already exist")); cb = ->
        return
    mkdirp(dir, (err) ->
      cb(err)
    )
  )

module.exports = {
  load: (cb) ->
    cb()
  oncall: (obj, params, cb) ->
    params.pluginParameters ?= {}
    params.pluginParameters.output ?= {}
    params.pluginParameters.output.outputDirectoryList ?= []

    jelly = @getParentOfClass('Jelly')

    if obj.File == true
      async.each(params.pluginParameters.output.outputDirectoryList, (dir, cb) ->
        mkdirIfNotExist("#{jelly.getRootDirectory()}/#{dir}", (err) ->
          if err
            cb(err); cb = ->
            return

          cb()
        )
        ;
      , cb)
      return
    cb(); cb = ->
  unload: (cb) ->
    cb()
}
