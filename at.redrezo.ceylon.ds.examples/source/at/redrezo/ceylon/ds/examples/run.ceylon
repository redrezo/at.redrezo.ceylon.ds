import at.redrezo.ceylon.ds {
	ServiceContext,
	ds,
	inject,
	service,
	component,
	activate
}

import ceylon.language.meta.declaration {
	Module
}


shared void run() {
	
	Module m = `module at.redrezo.ceylon.ds.examples`;
	
	ServiceContext ctx = ds.getContext(m);
	
	// this publishes all the services of the module
	ctx.publishAnnotatedServices();
	
	TestService? t = ctx.resolveService<TestService>();
	if (is TestService t) {
		t.testMe();
	}
	else {
		print("TestService not found");
	}
	
}

// test interface
shared interface Fail {
	
}
shared interface TestService {
	shared formal void testMe();
}

shared interface TestDependency {
	shared formal String getMessage();
}

// test implementation 



component
service(`interface TestService`)
service(`interface Fail`)
class TestServiceImpl(messageProvider) satisfies TestService {
	shared variable inject TestDependency messageProvider;
	
	shared variable inject TestDependency? message = null;
	
	shared actual void testMe() {
		
		print("Yeah: This is Sparta! message=``messageProvider.getMessage()``");
		
		value tmp = message;
		if (is TestDependency tmp) {
			print("Yeah: testMe on TestServiceImpl message=``tmp.getMessage()``");
		}
		else {
			print("Yeah: testMe on TestServiceImpl message not injected!");
		}
	}
}

component
service(`interface TestDependency`)
class TestDependencyImpl() satisfies TestDependency {
	shared actual String getMessage() {
		return "Hello Dependency Injection!";
	}
	
	activate
	shared void activate() {
		print("I was activated!!!!!!");
	}
}

