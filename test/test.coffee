pluginDir = __dirname + '/../'
toType = (obj) -> ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()
assert = require('chai').assert;
request = require('request')
shell = require('shelljs')
fs = require('fs')
path = require('path')

try
  jy = require('jellyjs')
catch e
  root = __dirname + '/../../../../';
  jy = require("#{root}/index.js");

describe('#Plugin::output', ->
  #---------------
  it('Should work on File entities', (cb) ->
    shell.rm('-rf', "#{__dirname}/demo/public")
    jelly = new jy.Jelly()
    jelly.boot({
      directory:"#{__dirname}/demo"
      packagePlugins:['template']
      folderPlugins:[{name:'output', directory:pluginDir}]
      localRequire: (elm, cb) ->
        try
          cb(null, require.resolve(elm)); cb = ->
        catch e
          cb(e); cb = ->
    }, (err) ->
      if err
        cb(err); cb = ->
        return
      fs.readFile("#{__dirname}/demo/public/module1-file1.tpl", (err, data) ->
        if err
          cb(new Error("The generated extension does not work as expected: #{err.message}")); cb = ->
          return
        try
          assert.equal(data+'', 'TPL TEST', 'The file content should be equal to the original content')
          cb(); cb = ->
        catch e
          cb(e); cb = ->
      )
    )
  )
 #---------------
  it('Should expose a "file-list" sharedObject', (cb) ->
    shell.rm('-rf', "#{__dirname}/demo/public")
    jelly = new jy.Jelly()
    jelly.boot({
      directory:"#{__dirname}/demo"
      packagePlugins:['template']
      folderPlugins:[{name:'output', directory:pluginDir}]
      localRequire: (elm, cb) ->
        try
          cb(null, require.resolve(elm)); cb = ->
        catch e
          cb(e); cb = ->
    }, (err) ->
      if err
        cb(err); cb = ->
        return
      try
        content = jelly.getSharedObjectManager().getObject('output', 'file-list')
        assert.equal(toType(content), 'object')
        content = content.getCurrentContent()
        assert.equal(toType(content), 'array')
        assert.equal(content.length, 1)
        assert.equal(path.normalize(content[0].absoluteFilename), path.normalize("#{__dirname}/demo/public/module1-file1.tpl"))
        assert.equal(content[0].filename, 'module1-file1.tpl')
        assert.equal(toType(content[0].obj), 'object')
        assert.equal(content[0].obj.File, true)
        assert.equal(content[0].obj.getId(), 'module1-file1.tpl')
        cb()
      catch e
        cb(e)      
    )
  )
  #--------
  it('Should expose a method to use with templates', (cb) ->
    shell.rm('-rf', "#{__dirname}/demoModule/public")
    jelly = new jy.Jelly()
    jelly.boot({
      directory:"#{__dirname}/demoModule"
      packagePlugins:['template']
      folderPlugins:[{name:'output', directory:pluginDir}]
      localRequire: (elm, cb) ->
        try
          cb(null, require.resolve(elm)); cb = ->
        catch e
          cb(e); cb = ->
    }, (err) ->
      cb()
    )
  ) 
)