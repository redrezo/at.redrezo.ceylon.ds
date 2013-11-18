import at.redrezo.ceylon.ds {
	ServiceAnnotation,
	ServiceContext,
	InjectAnnotation,
	DS,
	ComponentAnnotation
}

import ceylon.collection {
	MutableMap,
	HashMap,
	MutableList,
	LinkedList
}
import ceylon.language.meta.declaration {
	Module,
	InterfaceDeclaration,
	Package,
	ClassDeclaration,
	ValueDeclaration,
	OpenType,
	OpenInterfaceType,
	FunctionOrValueDeclaration,
	OpenUnion
}
import ceylon.language.meta.model {
	Interface,
	Type,
	Class
}

object serviceRegistry {
	
	MutableList<ServiceDefinition> services = LinkedList<ServiceDefinition>();
	
	shared void publishServiceInstance({InterfaceDeclaration*} provides, Object instance, {<String->Object>*} properties) {
		
	}
	
	shared void publishService({InterfaceDeclaration*} provides, ClassDeclaration clazz, {<String->Object>*} properties) {
		//print("Registry: publishService(``provides``, ``clazz``)");
		//for (InterfaceDeclaration d in provides)  {
		//	print("``d`` -> ``d.openType``");
		//}
		
		ServiceDefinition def = ServiceDefinition(provides, clazz);
		def.findDependencies();
		value ok = def.checkDependencies();
		if (ok) {
			print("Registry: Service satisfied: ``def``");
		}
		else {
			print("Registry: Service unsatisfied: ``def``");
		}
		services.add(def);
		
		
		checkAllServiceDependencies();
	}
	
	void checkAllServiceDependencies() {
		for (def in services.filter((ServiceDefinition elem) => !elem.isResolved())) {
			value ok = def.checkDependencies();
			if (ok) {
				print("Registry: Service satisfied: ``def``");
			}
			else {
				print("Registry: Service still unsatisfied: ``def``");
			}
		}
	}
	
	shared {ServiceDefinition*} findServices(InterfaceDeclaration intf) => 
		services.filter((ServiceDefinition elem) => elem.satisfiedProvides.contains(intf.openType));
	
	
	
}

class ServiceDefinition({InterfaceDeclaration*} provides, ClassDeclaration clazz) {
	// filter and store all satisfied types
	shared {OpenInterfaceType*} satisfiedProvides = { for (elem in provides.map((InterfaceDeclaration elem) => elem.openType)) 
		if (is OpenInterfaceType elem) 
		if (clazz.satisfiedTypes.contains(elem)) elem 
	};
	
	//FunctionOrValueDeclaration[] activateMethods = clazz.annotatedMemberDeclarations<FunctionOrValueDeclaration, ComponentActivateAnnotation>();
	
	variable Boolean resolved = false;
	
	MutableMap<ValueDeclaration, OpenInterfaceType> injectDependencies = HashMap<ValueDeclaration, OpenInterfaceType>();
	
	shared variable Anything? instance = null;
	
	shared Boolean isResolved() => resolved;
	
	
	shared S? getServiceInstance<S>() {
		value i = instance;
		if (!is Null i) {
			if (is S i) {
				return i;
			}
		}
		
		if (isResolved()) {
			instance = instantiate();
			inject(instance);
			// TODO call activate methods
			value x = instance;
			if (is S x) {
				return x;
			}
		}
		return null;
	}
	
	shared Anything lookup(OpenInterfaceType t) {
		//print("lookup(``t``)");
		value services = serviceRegistry.findServices(t.declaration);
		value first = services.first;
		if (is ServiceDefinition first) {
			//print(" -> found ``first``");
			Anything? la = first.getServiceInstance<Anything>();
			//print(" -> instance is ``la?.string else "NULL"``");
			if (!is Null la) {
				return la;
			}
			return null;
		}
		//print(" -> found nothing!!!!");
		return null;
	}
	
	
	shared Anything instantiate() {
		if (clazz.parameterDeclarations.empty) {
			print("creating new instance");
			return clazz.instantiate();
		}
		else {
			{OpenInterfaceType*} types ={ for (elem in clazz.parameterDeclarations
				.map((FunctionOrValueDeclaration elem) => elem.openType))
				if (is OpenInterfaceType elem) elem
			};
			
			value args = types.map<Anything>((OpenInterfaceType elem) => lookup(elem));
			
			Class<Anything,Nothing> classApply = clazz.classApply<Anything>();
			
			classApply.apply(*args);
			
			return clazz.instantiate(empty, *args);
		}
		
		
	}
	
	shared void findDependencies() {
		for (ValueDeclaration decl in clazz.annotatedMemberDeclarations<ValueDeclaration, InjectAnnotation>()) {
			
			print(" * ``decl`` needs injection! ``decl.openType``");
			OpenType type = decl.openType;
			//print("Type info ``type``");
			if (is OpenUnion type) {
				//print(" OpenUnion");
				//print(" - ``type.caseTypes``");
				OpenType? realType = type.caseTypes.filter((OpenType elem) => elem != `Null`.declaration.openType).first;
				if (is OpenInterfaceType realType) {
					//print(" - ``realType``");
					injectDependencies.put(decl, realType);
				}
				else {
					print("Error: cannot handle dependency: ``decl``");
				}
			}
			else if (is OpenInterfaceType type) {
				//print(" OpenInterfaceType");
				//print(" - ``type.declaration``");
				
				injectDependencies.put(decl, type);
			}
			
			else {
				print("Error: cannot handle dependency: ``decl``");
			}
		//	decl.memberSet(instance, newValue);
		}
	}
	
	shared {InterfaceDeclaration*} getUnresolvedDependencies() =>
			injectDependencies.values.map((OpenInterfaceType elem) => elem.declaration).filter((InterfaceDeclaration elem) => serviceRegistry.findServices(elem).empty);
	
	shared Boolean checkDependencies() {
		{InterfaceDeclaration*} unresolved = getUnresolvedDependencies();
		if (!unresolved.empty) {
			print("The following dependencies are not yet resolved: ``unresolved``");
		}
		resolved = unresolved.empty;
		return resolved;
	}
	
	shared void inject(Anything target) {
		if (!is Null target) {
			for (ValueDeclaration v in injectDependencies.keys) {
				OpenInterfaceType? type = injectDependencies.get(v);
				if (is OpenInterfaceType type) {
					v.memberSet(target, lookup(type));
				}
			}
		}
	}
	
	shared actual String string => "ServiceDefinition(``satisfiedProvides``)";
}


shared class DSImpl() satisfies DS {
	MutableMap<Module, ServiceContext> contexts = HashMap<Module, ServiceContext>();

	shared actual ServiceContext getContext(Module m) {
		ServiceContext? ctx = contexts.get(m);
		if (is ServiceContext ctx) {
			return ctx;
		}
		else {
			ServiceContext newContext = ServiceContextImpl(m);
			contexts.put(m, newContext);
			return newContext;
		}
	}
	
}

class ServiceContextImpl(Module m) satisfies ServiceContext {

	shared actual Module getModule() => m;
	
	shared actual void publishAnnotatedServices() {
		for (Package p in m.members) {
			print("searching in ``p``");
			for (ClassDeclaration clazz in p.annotatedMembers<ClassDeclaration, ComponentAnnotation>()) {
				print("found service: ``clazz``");
				{InterfaceDeclaration*} provides = clazz.annotations<ServiceAnnotation>().map((ServiceAnnotation elem) => elem.intf);
				serviceRegistry.publishService(provides, clazz, empty);
			}
		}
	}
	
	shared actual void publishService({InterfaceDeclaration+} provides, Object instance, {<String->Object>*} properties) {
	
	}
	
	shared actual S? resolveService<S>() {
		Type<S> type = `S`;
		if (is Interface<S> type) {
			value f = serviceRegistry.findServices(type.declaration).first;
			if (is ServiceDefinition f) {
				return f.getServiceInstance<S>();
			}
		}
		
		return null;
	}
	
	
}


