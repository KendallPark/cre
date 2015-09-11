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
    CollapsibleNav = ReactBootstrap.CollapsibleNav

    <Navbar brand='CRE Dash' className="navbar-default navbar-fixed-top" toggleNavKey={-1}>
      <CollapsibleNav eventKey={-1}>
        <Nav activeKey={this.state.currentTab} onSelect={this.onChangeTab} navbar>
          <NavItem eventKey={0} href='#UpToDate'>UpToDate</NavItem>
          <NavItem eventKey={1} href='#ClinicalKey'>ClinicalKey</NavItem>
          <NavItem eventKey={2} href='#AccessMedicine'>AccessMedicine</NavItem>
          <NavItem eventKey={3} href='#Wikipedia'>Wikipedia</NavItem>
          <NavItem eventKey={4} href='#PubMed'>PubMed</NavItem>
          <NavItem eventKey={5} href='#Labs'>Labs</NavItem>
          <NavItem eventKey={6} href='#Drugs'>Drugs</NavItem>
        </Nav>
        <Nav navbar right>
          <SearchEverything />
        </Nav>
      </CollapsibleNav>
    </Navbar>
