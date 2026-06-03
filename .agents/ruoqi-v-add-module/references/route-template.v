// TEMPLATE: Route registration — add to route/route_xxx.v
// Replace xxx, Xxx, XxxApp with actual module names.
// Choose the correct registration method: no_auth, sys, or core.

// In the route file:
//   import service.xxx_api.xxx { XxxApp }
//
// In the route function body:
//   app.register_routes_no_auth[XxxApp, Context](mut &XxxApp{}, '/prefix/xxx', mut ctx)
//   -- or --
//   app.register_routes_sys[XxxApp, Context](mut &XxxApp{}, '/prefix/xxx', mut ctx)
//   -- or --
//   app.register_routes_core[XxxApp, Context](mut &XxxApp{}, '/prefix/xxx', mut ctx)
//
// Registration methods differ by authentication level:
//   no_auth — public endpoints, no JWT required
//   sys     — system admin JWT required
//   core    — core business JWT + tenant context required
