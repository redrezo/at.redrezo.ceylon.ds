import ceylon.language.meta.declaration {
	Module,
	InterfaceDeclaration,
	FunctionDeclaration,
	ClassDeclaration,
	ValueDeclaration
}
import net.redrezo.ceylon.ds.impl { DSImpl }

shared interface DS {
	"returns the `ServiceContext` for a Module"
	shared formal ServiceContext getContext(Module m);
}

shared object ds extends DSImpl() {}

shared interface ServiceContext {
	"returns the `Module` associated with this `ServiceContext`"
	shared formal Module getModule();
	"programatically publishes a service (Not implemented yet)"
	shared formal void publishService({InterfaceDeclaration+} provides, Object instance, {<String->Object>*} properties);
	"resolves a service"
	shared formal S? resolveService<S>();
	"publishes all annotated components in this module"
	shared formal void publishAnnotatedServices();
}

// annotations

shared final annotation class ComponentAnnotation()
		satisfies OptionalAnnotation<ComponentAnnotation, ClassDeclaration> {
}

shared annotation ComponentAnnotation component() => ComponentAnnotation();


shared final annotation class ServiceAnnotation(intf)
		satisfies SequencedAnnotation<ServiceAnnotation, ClassDeclaration> {
	shared InterfaceDeclaration intf;
}

shared annotation ServiceAnnotation service(InterfaceDeclaration intf) => ServiceAnnotation(intf);


shared final annotation class ComponentActivateAnnotation()
	satisfies OptionalAnnotation<ComponentActivateAnnotation, FunctionDeclaration> {}
shared annotation ComponentActivateAnnotation activate() => ComponentActivateAnnotation();

shared final annotation class InjectAnnotation()
		satisfies OptionalAnnotation<InjectAnnotation, ValueDeclaration> {
	
}

shared annotation InjectAnnotation inject() => InjectAnnotation();
