import ceylon.language.meta.declaration { Module, InterfaceDeclaration, FunctionDeclaration, ClassDeclaration, ValueDeclaration }

shared interface DS {
	"returns the `ServiceContext` for a Module"
	shared formal ServiceContext getContext(Module m);
}

shared interface ServiceContext {
	shared formal Module getModule();
	shared formal void publishService({InterfaceDeclaration+} provides, Object instance, {<String->Object>*} properties);
	shared formal S? resolveService<S>();
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
