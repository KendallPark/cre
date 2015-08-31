#= require ./search_store
@SearchResults = React.createClass
  displayName: "SearchResults"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("SearchStore")]

  getDefaultProps: ->
    flux: globalFlux

  getStateFromFlux: ->
    f = @getFlux()
    f.store("SearchStore").getState()

  getUpToDateUrl: ->
    query = @state.query.replace(" ", "+")
    url = "//www.uptodate.com/contents/search?search=#{query}"
    url

  getClinicalKeyUrl: ->
    query = @state.query.replace(" ", "%2520")
    url = "//www.clinicalkey.com/#!/search/#{query}"
    url = "//www.clinicalkey.com/" if query is ""
    url

  getAccessMedUrl: ->
    query = @state.query.replace(" ", "+")
    url = "//accessmedicine.mhmedical.com/SearchResults.aspx?q=#{query}"
    url = "//accessmedicine.mhmedical.com/" if query is ""
    url

  getWikipediaUrl: ->
    query = @state.query.replace(" ", "+")
    url = "//en.wikipedia.org/wiki/Special:Search?search=#{query}&go=Go"
    url = "//www.wikipedia.org/" if query is ""
    url

  render: ->
    console.log @upToDateUrl

    <div>
      <div key="UTD" className={if @state.currentTab is 0 then "on-top" else "make-clear" }>
        <EmbeddedPage url={this.getUpToDateUrl()} />
      </div>
      <div key="CK" className={if @state.currentTab is 1 then "on-top" else "make-clear" }>
        <EmbeddedPage url={this.getClinicalKeyUrl()} />
      </div>
      <div key="AM" className={if @state.currentTab is 2 then "on-top" else "make-clear" }>
        <EmbeddedPage url={this.getAccessMedUrl()} />
      </div>
        <div key="WK" className={if @state.currentTab is 3 then "on-top" else "make-clear" }>
          <EmbeddedPage url={this.getWikipediaUrl()} />
        </div>
    </div>

EmbeddedPage = React.createClass
  displayName: "EmbeddedPage"
  shouldComponentUpdate: (newProps, newState) ->
    if newProps.url is @props.url
      return false
    true
  render: ->
    console.log "rendering"
    <object data={this.props.url} width="100%" height="100%">
      <embed src={this.props.url} width="100%" height="100%"></embed>
      Error: Embedded data could not be displayed.
    </object>
