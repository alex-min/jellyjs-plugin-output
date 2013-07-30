
module.exports = {
  load: (cb) ->
    cb()
  oncall: (obj, params, cb) ->
    if obj.File == true
      
      cb(); cb = ->
      return
    cb(); cb = ->
  unload: (cb) ->
    cb()
}
