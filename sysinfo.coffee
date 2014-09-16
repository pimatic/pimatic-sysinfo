module.exports = (env) ->

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  fs = env.require 'fs'
  Promise.promisifyAll(fs)

  ns = require('nsutil')
  Promise.promisifyAll(ns)

  path = require 'path'

  class SysinfoPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("SystemSensor", {
        configDef: deviceConfigDef.SystemSensor, 
        createCallback: (config) => return new SystemSensor(config, framework)
      })

    # ##LogWatcher Sensor
  class SystemSensor extends env.devices.Sensor

    constructor: (@config, framework) ->
      @id = config.id
      @name = config.name

      @attributes = {}
      # initialise all attributes
      for attr, i in @config.attributes
        do (attr) =>
          name = attr.name
          assert name in ['cpu', 'memory', "temperature", "dbsize", "diskusage"]

          @attributes[name] = {
            description: name
            type: "number"
          }

          switch name
            when "cpu"
              lastCpuTimes = null
              sum = (cput) -> cput.user + cput.nice + cput.system + cput.idle
              reschredule = ( -> Promise.resolve().delay(1000).then( -> getter() ) )
              getter = ( => 
                return ns.cpuTimesAsync().then( (res) => 
                  if lastCpuTimes?
                    lastAll = sum(lastCpuTimes)
                    lastBusy = lastAll - lastCpuTimes.idle
                    all = sum(res)
                    busy = all - res.idle
                    busy_delta = busy - lastBusy
                    all_delta = all - lastAll
                    if all_delta is 0
                      return reschredule()
                    lastCpuTimes = res    
                    return Math.round(busy_delta / all_delta * 10000) / 100
                  else
                    lastCpuTimes = res
                    return reschredule()
                )
              )
              @attributes[name].unit = '%'
            when "memory"
              getter = ( =>
                return ns.virtualMemoryAsync().then( (res) =>
                  return Math.round( (res.total - res.avail) / (1000*1000) * 100) / 100
                )
              )
              @attributes[name].unit = 'MB'
            when "diskusage"
              path = attr.path or '/'
              getter = ( =>
                return ns.diskUsageAsync(path).then( (res) =>
                  return Math.round(res.used / res.total * 10000) / 100 
                )
              )
              @attributes[name].unit = '%'
            when "temperature"
              getter = ( =>
                return fs.readFileAsync("/sys/class/thermal/thermal_zone0/temp")
                  .then( (rawTemp) -> (Math.round(rawTemp / 10) / 100) )
              )
              @attributes[name].unit = '°C'
            when "dbsize"
              databaseConfig = framework.config.settings.database
              unless databaseConfig.client is "sqlite3"
                throw new Error("dbsize is only supported for sqlite3")
              filename = path.resolve framework.maindir, '../..', databaseConfig.connection.filename
              getter = ( =>
                return fs.statAsync(filename).then( (stats) =>
                  return Math.round( stats.size / (1000*1000) * 100) / 100
                )
              )
              @attributes[name].unit = 'MB'
            else
              throw new Error("Illegal attribute name: #{name} in SystemSensor.")
          # Create a getter for this attribute
          @_createGetter(name, getter)
          setInterval( (=>
            getter().then( (value) =>
              @emit name, value
            ).catch( (error) =>
              env.logger.error "error updating syssensor value for #{name}:", error.message
              env.logger.debug error.stack
            )
          ), attr.interval or 10000)
      super()

  # ###Finally
  # Create a instance of my plugin
  sysinfoPlugin = new SysinfoPlugin
  # and return it to the framework.
  return sysinfoPlugin