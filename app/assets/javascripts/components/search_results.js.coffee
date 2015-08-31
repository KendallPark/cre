#= require ./search_store
Panel = ReactBootstrap.Panel
Accordion = ReactBootstrap.Accordion
Table = ReactBootstrap.Table

@SearchResults = React.createClass
  displayName: "SearchResults"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("SearchStore")]

  getDefaultProps: ->
    flux: globalFlux

  getInitialState: ->
    currentLabs: []

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

  onLabChange: (e) ->
    labs = e.split("&&")
    labs = [] if e is ""
    @setState { currentLabs: labs }

  render: ->
    acronyms = _.invert @props.labs.acronyms
    labOptions = _.map _.keys(@props.labs.labs), (lab) ->
      acron = acronyms[lab] || ""
      acron = " (#{acron})" if acron isnt ""

      value: lab
      label: "#{lab}#{acron}"

    panels = []
    _.each @state.currentLabs, (lab, i) =>
      labData = @props.labs.labs[lab]
      panels.push <Panel header={lab} eventKey={"#{i}"} key={i}>
          <Table>
            <thead>
              <tr>
                <th>Test/Range/Collection</th>
                <th>Physiologic Basis</th>
                <th>Interpretation</th>
                <th>Comments</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td dangerouslySetInnerHTML={{__html: labData.test}} />
                <td dangerouslySetInnerHTML={{__html: labData.basis}} />
                <td dangerouslySetInnerHTML={{__html: labData.interpretation}} />
                <td dangerouslySetInnerHTML={{__html: labData.comments}} />
              </tr>
            </tbody>
          </Table>
        </Panel>

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
      <div key="labs" className={if @state.currentTab is 4 then "on-top" else "make-clear" }>
        <div className="lab-search container">
          <div className="row">
            <div className="col-md-12 lab-select-container">
              <Select
                ref="labSelect"
                className="col-md-12 no-padding"
                value={this.state.currentLabs}
                delimiter="&&"
                multi={true}
                placeholder="search labs"
                options={labOptions}
                onChange={this.onLabChange} />
              <p className="labs-source">Source: <a  target="_blank" href="http://accessmedicine.mhmedical.com/content.aspx?bookid=503&sectionid=43474716">Pocket Guide to Diagnostic Tests, 6e. Access Medicine</a></p>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              <Accordion defaultActiveKey='0'>
                {panels}
              </Accordion>
            </div>
          </div>
        </div>
      </div>
    </div>

EmbeddedPage = React.createClass
  displayName: "EmbeddedPage"
  shouldComponentUpdate: (newProps, newState) ->
    if newProps.url is @props.url
      return false
    true
  render: ->
    <object data={this.props.url} width="100%" height="100%">
      <embed src={this.props.url} width="100%" height="100%"></embed>
      Error: Embedded data could not be displayed.
    </object>
