angular.module 'ngStopwatch.services'
.service 'stopwatch', ($interval)->
  idController = 0
  class StopWatch
    constructor: (config)->
      @id = ++idController
      @lapStarted = null

      initial = {
        name: "timer#{idController}"
        created: new Date().getTime()
        current: 0
        stopped: null
        laps: []
        currentLap: 0
        lastLap: null
        refreshRate: 100
        running: false
        autoRefresh: true
      }

      angular.merge @, initial
      @interval = null

      angular.merge @, config


      if @autoRefresh
        @trackCurrent()

      @start() unless config.suppressAutoStart


    getTime: ->
      if @running
        @stop()

      return @current

    start: ->
      return if @running
      @running = true
      @lastStart = new Date().getTime()

      unless !@autoRefresh
        @trackCurrent()

    stop: ->
      $interval.cancel(@interval)
      @interval = null
      now = new Date().getTime()
      return if !@running
      @running = false
      @stopped = now

      @current += @stopped - @lastStart
      @currentLap += @stopped - @lastStart

    reset: ->
      angular.merge @, {
        current: 0
        stopped: null
        laps: []
        currentLap: 0
        lastLap: null
      }

      @laps = []


    lap: ->
      return if !@running
      $interval.cancel(@interval) # cancel any pending tracking
      @interval = null
      now = new Date().getTime()
      @current += now - @lastStart
      @currentLap += now - @lastStart


      @lastLap = @currentLap
      @laps.push @lastLap

      @lastStart = now
      @currentLap = 0
      unless !@autoRefresh
        @trackCurrent()

    trackCurrent: ()->
      if @running
        self = @
        @interval = $interval ->
          now = new Date().getTime()
          self.current += now - self.lastStart
          self.currentLap += now - self.lastStart
          self.lastStart = now
        , @refreshRate

      else
        $interval.cancel(@interval)
        @interval = null





  return API = {
    create: (config)->
      return new StopWatch(config)
  }
