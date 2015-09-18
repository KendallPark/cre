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
    currentDrugs: []
    currentPharm: []
    drugInfoByName: {}

  getStateFromFlux: ->
    f = @getFlux()
    f.store("SearchStore").getState()

  getUpToDateUrl: ->
    query = @state.query.replace(" ", "+")
    rootUrl = "//www.uptodate.com"
    rootUrl = "//library.muhealth.org/mainSearch/UpToDate/UTD_IPcheck.php" if @props.off_campus and query is ""
    url = "#{rootUrl}/contents/search?search=#{query}"
    url = rootUrl if query is ""
    url

  getClinicalKeyUrl: ->
    query = @state.query.replace(" ", "%2520")
    rootUrl = "//www.clinicalkey.com"
    rootUrl = "//proxy.mul.missouri.edu/login?url=http://www.clinicalkey.com" if @props.off_campus
    url = "#{rootUrl}/#!/search/#{query}"
    url = rootUrl if query is ""
    url

  getAccessMedUrl: ->
    query = @state.query.replace(" ", "+")
    rootUrl = "//accessmedicine.mhmedical.com"
    rootUrl = "//proxy.mul.missouri.edu/login?url=http://accessmedicine.mhmedical.com" if @props.off_campus
    url = "#{rootUrl}/SearchResults.aspx?q=#{query}"
    url = rootUrl if query is ""
    url

  getWikipediaUrl: ->
    query = @state.query.replace(" ", "+")
    url = "//en.wikipedia.org/wiki/Special:Search?search=#{query}&go=Go"
    url = "//www.wikipedia.org/" if query is ""
    url

  getPubMedUrl: ->
    query = @state.query.replace(" ", "+")
    rootUrl = "//www.ncbi.nlm.nih.gov/pubmed"
    url = "#{rootUrl}/?term=#{query}"
    url = "//www.ncbi.nlm.nih.gov/pubmed?myncbishare=umochsclib&dr=abstract" if query is ""
    url

  onLabChange: (e) ->
    labs = e.split("&&")
    labs = [] if e is ""
    @setState { currentLabs: labs }

  onDrugChange: (e) ->
    drugs = e.split("&&")
    drugs = [] if e is ""
    if drugs.length > 0 and not @state.drugInfoByName[drugs[drugs.length - 1]]?
      @getDrugInfo(drugs[drugs.length - 1])
    @setState { currentDrugs: drugs }

  onPharmChange: (e) ->
    drugs = e.split("&&")
    drugs = [] if e is ""
    @setState { currentPharm: drugs }

  getDrugInfo: (drugName) ->
    $.ajax
      type: 'GET'
      url: """https://api.fda.gov/drug/label.json?search=generic_name:#{drugName}&limit=1"""
      success: (results) =>
        toChange = {}
        toChange[drugName] = { $set: results.results[0] }
        newState = React.addons.update @state.drugInfoByName, toChange
        @setState { drugInfoByName: newState }
      failure: (error) ->
        return

  drugOptions: (input, callback) ->
    return if input.length is 0
    return if typeof input is "object"
    searchTerm = input
    searchTerm = searchTerm.replace(" ", "%20")
    $.ajax
      type: 'GET'
      url: """https://api.fda.gov/drug/event.json?search=patient.drug.medicinalproduct:"#{searchTerm}"&count=patient.drug.openfda.generic_name&limit=1000"""
      success: (results) ->
        callback null,
          options: _.map results.results, (result) ->
            { value: result.term, label: result.term }
          complete: true
      failure: (error) ->
        callback error, null
        return

  getLabPanels: (labs) ->
    panels = []
    _.each labs, (lab, i) =>
      labData = @props.labs.labs[lab]
      panels.push <Panel header={lab} eventKey={"lab_#{i}"} key={i}>
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
    panels

  getDrugPanels: (drugs) ->
    panels = []
    _.each drugs, (drugName, i) =>
      drugData = @state.drugInfoByName[drugName]
      if drugData
        description = drugData.description || ["Not Found"]
        indications = drugData.indications_and_usage || ["Not Found"]
        mechanism = drugData.mechanism_of_action || ["Not Found"]
        reactions = drugData.adverse_reactions_table || ["Not Found"]
        generic_name = drugData.openfda.generic_name || ["Not Found"]
        brand_name = drugData.openfda.brand_name || ["Not Found"]
        route = drugData.openfda.route || ["Not Found"]
        pharm_class_epc = drugData.openfda.pharm_class_epc || ["Not Found"]
        panels.push <Panel header={drugName} eventKey={"#{i}"} key={i}>
            <table className="table">
              <thead>
                <tr>
                  <th>Generic Name</th>
                  <th>Brand Name</th>
                  <th>Route</th>
                  <th>Pharm Class</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>{generic_name.join(', ')}</td>
                  <td>{brand_name.join(', ')}</td>
                  <td>{route.join(', ')}</td>
                  <td>{pharm_class_epc.join(', ')}</td>
                </tr>
              </tbody>
            </table>
            <h3>Description</h3>
            <p>{description[0]}</p>
            <h3>Indications and Usage</h3>
            <p>{indications[0]}</p>
            <h3>Mechanism</h3>
            <p>{mechanism[0]}</p>
            <h3>Adverse Reactions</h3>
            <div dangerouslySetInnerHTML={{__html: reactions[0]}} />
          </Panel>
    panels

  getPharmPanels: (drugs) ->
    panels = []
    _.each drugs, (drugName, i) =>
      console.log drugName
      drugData = @props.pharm[drugName]
      console.log drugData
      if drugData
        features = []
        _.each _.omit(drugData.features, ["Class", "Similar Drug(s)"]), (description, feature) ->
          features.push <h4>{feature}</h4>
          features.push <p>{description}</p>
        panels.push <Panel header={drugName} eventKey={"drug_#{i}"} key={i}>
          <table className="table">
            <thead>
              <tr>
                <th>Category</th>
                <th></th>
                <th>Class</th>
                <th>Similar Drug(s)</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{drugData.category}</td>
                <td>{drugData.subcategory}</td>
                <td>{drugData.features.Class}</td>
                <td>{drugData.features["Similar Drug(s)"]}</td>
              </tr>
            </tbody>
          </table>
          <div className="drug-features">
            {features}
          </div>
        </Panel>
    panels

  render: ->
    acronyms = _.invert @props.labs.acronyms
    labOptions = _.map _.keys(@props.labs.labs), (lab) ->
      acron = acronyms[lab] || ""
      acron = " (#{acron})" if acron isnt ""

      value: lab
      label: "#{lab}#{acron}"

    pharmOptions = _.map _.keys(@props.pharm), (drug) ->
      value: drug
      label: drug

    labPanels = @getLabPanels(@state.currentLabs)
    # drugPanels = @getDrugPanels(@state.currentDrugs)
    pharmPanels = @getPharmPanels(@state.currentPharm)


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
      <div key="PM" className={if @state.currentTab is 4 then "on-top" else "make-clear" }>
        <EmbeddedPage url={this.getPubMedUrl()} />
      </div>
      <div key="labs" className={if @state.currentTab is 5 then "on-top" else "make-clear" }>
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
                {labPanels}
              </Accordion>
            </div>
          </div>
        </div>
      </div>
      <div key="drugs" className={if @state.currentTab is 6 then "on-top" else "make-clear" }>
        <div className="lab-search container">
          <div className="row">
            <div className="col-md-12 lab-select-container">
              <Select
                ref="drugSelect"
                className="col-md-12 no-padding"
                value={this.state.currentPharm}
                delimiter="&&"
                multi={true}
                placeholder="search drugs"
                options={pharmOptions}
                onChange={this.onPharmChange} />
              <p className="labs-source">Source: <a  target="_blank" href="http://www.amazon.com/gp/product/0702059579">Rang &amp; Dales Pharmacology Flash Cards Updated Edition</a></p>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              <Accordion defaultActiveKey='0'>
                {pharmPanels}
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
