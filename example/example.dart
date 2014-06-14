import 'package:Discharge/Discharge.dart';
import 'dart:io';

void main() {
  
  //simplest example
  simple();

  //resolving inheritance
  resolveInheritance();
  
  //static - for type hinting on return types
  withReturnTypeHints();
  
  //registering instance instead of type - no instantiation when resolving its type
  registerInstance();
  
  //registering services
  registerService();
  
  //using config file to create services
  configureServices();
}

void simple() {
  var discharge = new Discharge();
  discharge.container.register(A);
  discharge.container.register(D);
  D value = discharge.container.resolve(D);
  value.shout();
}

void resolveInheritance() {
  var discharge = new Discharge();
  discharge.container.register(B);
  discharge.container.register(D);
  D value = discharge.container.resolve(D); //will resolve D with B as its dependency (because B is A)
  value.shout();
}

void withReturnTypeHints() {
  StaticDischarge.init();
  StaticDischarge.container.register(A);
  StaticDischarge.container.register(D);
  D value = new StaticDischarge<D>().resolve(); //will typhint return type of D
  value.shout();
}

void registerInstance() {
  var discharge = new Discharge();
  var obj_a = new A("instance");
  discharge.container.registerInstance(obj_a); //will return objA when resolving type A
  discharge.container.register(D);
  D value = discharge.container.resolve(D);
  value.shout();
}

void registerService() {
  var discharge = new Discharge();
  var obj_a = new A("service");
  discharge.services.registerService('service_a', obj_a);
  print(discharge.services.getService('service_a').text);
}

void configureServices() {
  var configuration = new ServicesConfigurationProviderXml(new File('config/config.xml'));
  var discharge = new Discharge();
  discharge.container.register(A);
  discharge.container.register(D);
  discharge.services.configureServices(configuration);
  discharge.services.getService('service_d').shout(); 
  
  D d = discharge.container.resolve(D); //D will resolve with service_a autowired as type A
  d.shout();
}

class A {
  var text;  
  
  A([String this.text = "default", int number = 1]) {
    for (var i=1; i<number; i++) {
      text += text;
    }
  }
}

class B extends A {  
  B() : super("inherited", 1);
}

class C {
  C (int x, {y}) {
    
  }
}

class D {
  A a;

  D(A this.a);

  shout() {
    print(a.text);
  }
}
