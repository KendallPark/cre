constants = { SEARCH: "SEARCH", OPEN_TAB: "OPEN_TAB" }

SearchStore = Fluxxor.createStore
  initialize: ->
    @query = ""
    @currentTab = 0
    @bindActions(constants.SEARCH, @onSearch, constants.OPEN_TAB, @onTabChange)

  onSearch: (payload) ->
    @query = payload.query
    @emit("change")

  onTabChange: (payload) ->
    @currentTab = payload.tabNumber
    @emit("change")

  getState: ->
    { query: @query, currentTab: @currentTab }

actions =
  search: (query) ->
    @dispatch(constants.SEARCH, {query: query})
  openTab: (tabNumber) ->
    @dispatch(constants.OPEN_TAB, {tabNumber: tabNumber})

stores = { SearchStore: new SearchStore() }

@globalFlux = new Fluxxor.Flux(stores, actions)

@globalFlux.on "dispatch", (type, payload) ->
  console.log("[Dispatch]", type, payload)

@globalFlux.setDispatchInterceptor (action, dispatch) ->
  React.addons.batchedUpdates ->
    dispatch(action)
