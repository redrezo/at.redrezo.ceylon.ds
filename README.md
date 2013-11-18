at.redrezo.ceylon.ds
====================

declarative services runtime for ceylon

Usage
=====

The main entrypoint is the `ds` object. You can use it to retrieve a `ServiceContext` for your module:

    ServiceContext ctx = ds.getContext(`module my.little.module`);
The context is used to publish and resolve services. (For now publishing 
is only supported via the `publishAnnotatedServices` method)

So you need to make sure to call `ctx.publishAnnotatedServices();` if your module contains some service implementations


To resolve a service simply call

    MyServiceInterface service = ctx.resolveService<MyServiceInterface>();
   


