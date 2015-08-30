#= require ../search_store
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
        <NavItem eventKey={0} href='#'>UpToDate</NavItem>
        <NavItem eventKey={1} href='#'>ClinicalKey</NavItem>
        <NavItem eventKey={2} href='#'>AccessMedicine</NavItem>
        <NavItem eventKey={3} href='#'>Wikipedia</NavItem>
      </Nav>
      <Nav right>
        <SearchEverything />
      </Nav>
    </Navbar>
