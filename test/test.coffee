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
  
)