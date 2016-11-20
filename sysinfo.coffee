module.exports = (env) ->

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  fs = env.require 'fs'
  os = env.require 'os'
  Promise.promisifyAll(fs)

  si = require('systeminformation');


  path = require 'path'

  class SysinfoPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("SystemSensor", {
        configDef: deviceConfigDef.SystemSensor, 
        createCallback: (config) => return new SystemSensor(config, @framework)
      })

    # ##LogWatcher Sensor
  class SystemSensor extends env.devices.Sensor

    constructor: (@config, framework) ->
      @id = @config.id
      @name = @config.name

      @attributes = {}
      # initialise all attributes
      for attr, i in @config.attributes
        do (attr) =>
          name = attr.name
          assert name in [
            'cpu', 'memory', "memoryPercent", "processes",
            "temperature", "temperatureF", "dbsize", "diskusage",
            "memoryRss","memoryHeapUsed", "memoryHeapTotal", "uptime"
          ]

          @attributes[name] = {
            description: name
            type: "number"
          }

          switch name
            when "cpu"
              getter = ( =>
                return si.currentLoad().then( (res) =>
                  return Math.round(res.currentload * 10) / 10
                )
              )
              @attributes[name].unit = '%'
              @attributes[name].acronym = 'CPU'
            when "memory"
              getter = ( =>
                return si.mem().then( (res) =>
                  return res.used
                )
              )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'MEM'
            when "memoryPercent"
              getter = ( =>
                return si.mem().then( (res) =>
                  return Math.round(res.used / res.total * 1000) / 10
                )
              )
              @attributes[name].unit = '%'
              @attributes[name].acronym = 'MEMP'
            when "processes"
              getter = ( =>
                return si.processes().then( (res) =>
                  return res.all
                )
              )
              @attributes[name].unit = ''
              @attributes[name].acronym = 'PROCS'
            when "memoryRss"
              getter = ( => Promise.resolve(process.memoryUsage().rss) )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'RSS'
            when "memoryHeapUsed"
              getter = ( => Promise.resolve(process.memoryUsage().heapUsed) )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'HEAP'
            when "memoryHeapTotal"
              getter = ( => Promise.resolve(process.memoryUsage().heapTotal) )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'THEAP'
            when "diskusage"
              mountPath = attr.path?.toUpperCase() or '/'
              getter = ( =>
                return si.fsSize().then( (res) =>
                  match = (res.filter (i) -> i.mount.toUpperCase() is mountPath)
                  if match.length > 0
                    return Math.round(match[0].use * 10) / 10
                  else
                    return -1
                )
              )
              @attributes[name].unit = '%'
              @attributes[name].acronym = 'DISK'
            when "temperature"
              getter = ( =>
                return si.cpuTemperature().then( (res) =>
                  return Math.round(res.main * 10) / 10
                )
              )
              @attributes[name].unit = '°C'
              @attributes[name].acronym = 'T'
            when "temperatureF"
              getter = ( =>
                return si.cpuTemperature().then( (res) ->
                  if res.main >= 0
                    return (res.main * 1.8 / 1000) + 32
                  else
                    return res.main
              )
              @attributes[name].unit = '°F'
              @attributes[name].acronym = 'T'
            when "dbsize"
              databaseConfig = framework.config.settings.database
              unless databaseConfig.client is "sqlite3"
                throw new Error("dbsize is only supported for sqlite3")
              filename = path.resolve framework.maindir, '../..', databaseConfig.connection.filename
              getter = ( =>
                return fs.statAsync(filename).then( (stats) =>
                  return  stats.size
                )
              )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'DB'
            when "uptime"
              getter = ( => Promise.resolve(os.uptime()) )
              @attributes[name].unit = 's'
              @attributes[name].acronym = 'UP'
            else
              throw new Error("Illegal attribute name: #{name} in SystemSensor.")
          # Create a getter for this attribute
          @_createGetter(name, getter)
          # setup polling
          @_setupPolling(name, attr.interval or 10000)
      super()

    destroy: ->
      super()

  # ###Finally
  # Create a instance of my plugin
  sysinfoPlugin = new SysinfoPlugin
  # and return it to the framework.
  return sysinfoPlugin