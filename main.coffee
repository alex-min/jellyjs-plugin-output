mkdirp = require('mkdirp')
fs = require('fs')
path = require('path')
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

getOutputContentFromFile = (file, options) ->
  currentContent = file.getCurrentContent()
  if currentContent == null || typeof currentContent.content == 'undefined' || currentContent.content == null
    return null
  if options.searchForLastGeneratedExtension != true
    return currentContent
  if typeof options.allowedGeneratedExtensions == 'undefined' || options.allowedGeneratedExtensions == null
    return currentContent
  for ext in options.allowedGeneratedExtensions
    content = file.getLastContentOfExtension(ext)
    if content != null && typeof content.content != 'undefined' && content.content != null
      return content
  return null

getOutputFilenameFromFile = (file, content, options, cb) ->
  if options.useGeneratedExtensionsAsOutput != true
    return file.getId()
  filenameCore = path.basename(file.getId(), path.extname(file.getId()))
  extension = content.extension || file.getLastOfProperty('extension') || ''
  return "#{filenameCore}.#{extension}"


outputFile = (file, jelly, options, cb) ->
  self = @
  cb = cb || ->
  fileList = []

  @getSharedObjectManager().registerObject('output', 'file-list', [])
  async.each(options.outputDirectoryList, (dir, cb) ->
    dir = "#{jelly.getRootDirectory()}/#{dir}"
    mkdirIfNotExist(dir, (err) ->
      content = null
      filename = null
      async.series([
        (cb) -> 
          content = getOutputContentFromFile(file, options)
          if content == null
            self.getLogger().warn("Unable to find a content to output for file #{file.getId()}")
          cb(); cb = ->
        (cb) ->
          if content == null
            cb(); cb = ->
            return
          filename = getOutputFilenameFromFile(file, content, options)
          cb()
        (cb) ->
          fs.writeFile("#{dir}/#{filename}", content.content.toString(), (err) ->
            cb(err)
          )
      ], cb)
    )
  ,cb)


###
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
###



module.exports = {
  load: (cb) ->
    cb()
  oncall: (obj, params, cb) ->

    self = @
    params.pluginParameters ?= {}
    params.pluginParameters.output ?= {}
    params.pluginParameters.output.outputDirectoryList ?= []
    options = params.pluginParameters.output

    jelly = @getParentOfClass('Jelly')

    if obj.File == true
      outputFile.call(this, obj, jelly, options, cb)
      return
    cb(); cb = ->
  unload: (cb) ->
    cb()
}
