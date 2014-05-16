# @reference http://stackoverflow.com/a/11850027
class Skanetrafiken extends Factory
  constructor: ($log, $http, $q, address, DATE_CONFIG) ->
    $http.defaults.useXDomain = yes

    _errorMessages =
      xhrError: 'The server didn\'t respond on request.'
      docs: 'See docs for more information.'
      invalidObject: 'Please pass valid object as parameter.'
      invalidKeys: 'Please pass valid key or keys.'
      invalidType: 'Please pass valid type.'

    # @private
    # @TODO: Find all possibilities
    _findTypeNumber = (type) ->
      return unless type
      return '0' if type is 'STOP_AREA'

    # Get results/journey
    # @param {Object}
    results = (params) ->

      try
        unless angular.isObject params
          throw new TypeError "#{_errorMessages.invalidObject} #{_errorMessages.docs}"
        else if angular.isUndefined params.from_id and angular.isUndefined params.to_id
          throw new Error "#{_errorMessages.invalidKeys} #{_errorMessages.docs}"
        if params.time or params.date
          httpParams = angular.copy params

      catch err
        $log.error "#{err.name}: #{err.message}"
        return

      # time/date object.
      httpParams.time = new Date(params.time).toLocaleTimeString('sv-SE', DATE_CONFIG.time) if params.time
      httpParams.date = new Date(params.date).toLocaleDateString('sv-SE', DATE_CONFIG.date) if params.date

      $http.get "#{address}results",
        cache: no
        params: httpParams or params
      .then (response) ->
        return response.data
      .catch (err) ->
        # Error
        throw new Error _errorMessages.xhrError
      .finally ->
        # Cleanup
        # TODO: Dont know if this has any positive effect on memory management.
        # Though, if it does, having null is better then length.
        # @see http://jsperf.com/delete-variable
        (httpParams = null) if httpParams

    # Find nearest station
    # @param {Object}
    find = (params) ->

      try
        unless angular.isObject(params)
          throw new TypeError "#{_errorMessages.invalidObject} #{_errorMessages.docs}"
        else if angular.isUndefined params.lng or angular.isUndefined params.lat
          throw new ReferenceError "#{_errorMessages.invalidKeys} #{_errorMessages.docs}"
        else unless angular.isString(params.lng and params.lat) or angular.isNumber(params.lng and params.lat)
          throw new TypeError "#{_errorMessages.invalidType} #{_errorMessages.docs}"
      catch err
        return throw new Error "#{err.name}: #{err.message}"

      $http.get "#{address}find",
        cache: yes
        params: params
      .then (response) ->
        return response.data
      , (err) ->
        return throw new Error err.statusText

    # Get transport types.
    types = ->
      $http.get "#{address}types",
        cache: yes
      .then (response) ->
        return response.data
      .catch (err) ->
        # Error
        throw new Error _errorMessages.xhrError

    # Get Schedule
    # @param {Object}
    schedule = (params) ->

      try
        unless angular.isObject params
          throw new TypeError "#{_errorMessages.invalidObject} #{_errorMessages.docs}"
        else if angular.isUndefined params.id
          throw new ReferenceError "#{_errorMessages.invalidKeys} #{_errorMessages.docs}"
        else unless angular.isString(params.id) or angular.isNumber(params.id)
          throw new Error "#{_errorMessages.invalidType} #{_errorMessages.docs}"
      catch err
        $log.error "#{err.name}: #{err.message}"
        return

      $http.get "#{address}schedule",
        cache: yes
        params: params
      .then (response) ->
        return response.data
      .catch (err) ->
        # Error
        throw new Error _errorMessages.xhrError

    # Search station
    # @param {Object}
    search = (params) ->

      try
        unless angular.isObject params
          throw new TypeError "#{_errorMessages.invalidObject} #{_errorMessages.docs}"
        else if angular.isUndefined params.q
          throw new ReferenceError "#{_errorMessages.invalidKeys} #{_errorMessages.docs}"
        else unless angular.isString(params.q)
          throw new Error "#{_errorMessages.invalidType} #{_errorMessages.docs}"
      catch err
        $log.error "#{err.name}: #{err.message}"
        return

      $http.get "#{address}search",
        cache: yes
        params: params
      .then (response) ->
        return response.data.startpoints.point
      , (err) ->
        throw new Error _errorMessages.xhrError

    # Query locations
    # @param {Object}
    query = (params) ->

      try
        unless angular.isObject params
          throw new TypeError "#{_errorMessages.invalidObject} #{_errorMessages.docs}"
        else if angular.isUndefined params.from and angular.isUndefined params.to
          throw new ReferenceError "#{_errorMessages.invalidKeys} #{_errorMessages.docs}"
        else unless angular.isString(params.from and params.to)
          throw new Error "#{_errorMessages.invalidType} #{_errorMessages.docs}"
      catch err
        $log.error "#{err.name}: #{err.message}"
        return

      $http.get "#{address}query",
        cache: yes
        params: params
      .then (response) ->
        return response.data
      .catch (err) ->
        # Error
        throw new Error _errorMessages.xhrError


    return {
      find: find
      types: types
      schedule: schedule
      search: search
      query: query
      results: results
    }

