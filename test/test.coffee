pluginDir = __dirname + '/../'
toType = (obj) -> ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()
assert = require('chai').assert;
request = require('request')

try
  jy = require('jellyjs')
catch e
  root = __dirname + '/../../../../';
  jy = require("#{root}/index.js");

describe('#Plugin::output', ->
  #---------------
  it('Should work on File entities', (cb) ->
    jelly = new jy.Jelly()
    jelly.boot({
      directory:"#{__dirname}/demo"
      packagePlugins:['template']
      folderPlugins:[{name:'output', directory:pluginDir}]
      localRequire: (elm, cb) ->
        try
          cb(null, require.resolve(elm))  
        catch e
          cb(e)
    }, (err) ->
      
      cb(err)
    )
  )  
)