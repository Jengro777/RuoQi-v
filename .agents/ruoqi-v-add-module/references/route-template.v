// TEMPLATE: Route registration — add to route/route_xxx.v
// Replace xxx, Xxx, Xxx with actual module names.
// Choose the correct registration method: no_auth, sys, or core.

// In the route file:
//   import service.xxx_api.xxx { Xxx }
//
// In the route function body:
//   app.register_routes_no_auth[Xxx, Context](mut &Xxx{}, '/prefix/xxx', mut ctx)
//   -- or --
//   app.register_routes_sys[Xxx, Context](mut &Xxx{}, '/prefix/xxx', mut ctx)
//   -- or --
//   app.register_routes_core[Xxx, Context](mut &Xxx{}, '/prefix/xxx', mut ctx)
//
// Registration methods differ by authentication level:
//   no_auth — public endpoints, no JWT required
//   sys     — system admin JWT required
//   core    — core business JWT + tenant context required
