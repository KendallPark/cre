#= require ../search_store
@SearchEverything = React.createClass
  displayName: "SearchEverything"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("SearchStore")]

  getDefaultProps: ->
    flux: globalFlux

  getStateFromFlux: ->
    f = @getFlux()
    f.store("SearchStore").getState()

  onKeyPress: (e) ->
    if e.key is "Enter"
      query = @refs.search.getDOMNode().value
      @getFlux().actions.search(query)

  render: ->
    <div className="navbar-form navbar-right">
      <input ref="search" type="text" className="form-control search-everything" placeholder="search everything" onKeyPress={this.onKeyPress} />
    </div>
