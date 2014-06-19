import "package:unittest/unittest.dart";
import "package:mock/mock.dart";
import "package:Discharge/Discharge.dart";
import "dart:io";

void main() {
  test("Discharge services can register service", () {
    Discharge discharge = new Discharge();
    A a = new A();
    expect(() => discharge.services.registerService("service_a", a), returnsNormally);
  });

  test("Discharge services can check if it has registered service", () {
    Discharge discharge = new Discharge();
    A a = new A();
    discharge.services.registerService("service_a", a);
    expect(discharge.services.hasService("service_a"), equals(true));
    expect(discharge.services.hasService("service_b"), equals(false));
  });

  test("Discharge services can get registered service", () {
    Discharge discharge = new Discharge();
    A a = new A();
    discharge.services.registerService("service_a", a);
    expect(discharge.services.getService("service_a"), equals(a));
  });

  test("Discharge services throws when getting unregistered service", () {
    Discharge discharge = new Discharge();
    A a = new A();
    expect(() => discharge.services.getService("service_a"), throws);
  });

  test("Discharge services can unregister service", () {
    Discharge discharge = new Discharge();
    A a = new A();
    discharge.services.registerService("service_a", a);
    expect(() => discharge.services.unregisterService("service_a"), returnsNormally);
    expect(discharge.services.hasService("service_a"), equals(false));
  });

  //only testing the basics, to test the correct behavior, write behavior tests
  test("Discharge services can read services configuration provider", () {
    Discharge discharge = new Discharge();
    var config_provider = new MockServiceConfigurationProvider();
    config_provider.when(callsTo("get services_configurations")).alwaysReturn({});
    expect(() => discharge.services.configureServices(config_provider), returnsNormally);
  });
}

//Mocks
class MockServiceConfigurationProvider extends Mock implements ServicesConfigurationProvider {}

//Classes for test purposes
class A {
  var text;

  A([String this.text = "default", int number = 1]) {
    for (var i=1; i<number; i++) {
      text += text;
    }
  }

  A.named() {
    this.text = "named";
  }

  A.withNamedParameter({String this.text:"default_named_param"});
}

class B extends A {
  B([String text = "inherited"]) : super(text);
}

class C extends B {
  C([String text = "inherited_deep"]) : super(text);
  C.named([String text = "inherited_deep_named"]) : super(text);
}

class D {
  A a;

  D(A this.a);

  D.named({A this.a});

  shout() {
    print(a.text);
  }
}

class E extends A {
  var text = "parameter value";
}