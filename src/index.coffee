Java = require('java')
fs = require('fs')
Commands = require('./commands')

module.exports = class Selenium
  @DEBUG = process.env.NODE_DEBUG && /selenium/.test(process.env.NODE_DEBUG)
  @DEBUG_PREFIX = 'Selenium: '

  found = false
  extDir = fs.realpathSync(__dirname + '/../ext')
  fs.readdirSync(extDir).map (jarname) ->
    abspath = fs.realpathSync(extDir + '/' + jarname)
    console.log "Selenium: Jarfile = #{abspath}" if @DEBUG
    Java.classpath.push(abspath)
    found = true

  throw new Error("Selenium RC JAR file NOT found in #{extDir}!  (did you run 'npm install'?)") unless found

  Java.classpath.push(__dirname)
  SeleniumWrapper = Java.import('SeleniumWrapper')

  constructor: (options = {}) ->
    @seleniumWrapper = new SeleniumWrapper(options.url || '')
    @seleniumWrapper.setProxySync(options.proxy) if options.proxy

  openBrowser: () ->
    @selenium = @seleniumWrapper.openBrowserSync()

  log: (msg) ->
    console.log "#{DEBUG_PREFIX}#{msg}"

js2hashMap = (obj) ->
  hashMap = new HashMap
  for k, v of obj
    hashMap.put(""+k, v)
  return hashMap

for cmd in Commands
  do (cmd) ->
    Selenium.prototype[cmd] = () ->
      throw new Error("Browser has not been opened yet") unless @selenium
      @log "Calling #{cmd}" if @DEBUG
      return @selenium[cmd + 'Sync'].apply(@selenium, arguments)


