#= require ./search_store
@CRENavbar = React.createClass
  displayName: "Navbar"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("SearchStore")]

  getDefaultProps: ->
    flux: globalFlux

  getStateFromFlux: ->
    f = @getFlux()
    f.store("SearchStore").getState()

  onChangeTab: (tabNumber) ->
    @getFlux().actions.openTab(tabNumber)

  render: ->
    Navbar = ReactBootstrap.Navbar
    Nav = ReactBootstrap.Nav
    NavItem = ReactBootstrap.NavItem

    <Navbar brand='CRE Dash' className="navbar-default navbar-fixed-top">
      <Nav activeKey={this.state.currentTab} onSelect={this.onChangeTab}>
        <NavItem eventKey={0} href='#UpToDate'>UpToDate</NavItem>
        <NavItem eventKey={1} href='#ClinicalKey'>ClinicalKey</NavItem>
        <NavItem eventKey={2} href='#AccessMedicine'>AccessMedicine</NavItem>
        <NavItem eventKey={3} href='#Wikipedia'>Wikipedia</NavItem>
        <NavItem eventKey={4} href='#PubMed'>PubMed</NavItem>
        <NavItem eventKey={5} href='#Labs'>Labs</NavItem>
      </Nav>
      <Nav right>
        <SearchEverything />
      </Nav>
    </Navbar>
