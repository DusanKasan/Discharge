import "package:unittest/unittest.dart";
import "package:discharge/discharge.dart";

void main() {
  test("Discharge container can register types", () {
    Discharge discharge = new Discharge();
    discharge.container.register(A);
    expect(discharge.container.type_map, containsPair(A, isNotNull));

    discharge.container.register(C, named_constructor: "named", for_type: B);
    expect(discharge.container.type_map, containsPair(B, isNotNull));
  });

  test("Discharge container can register types", () {
    Discharge discharge = new Discharge();
    discharge.container.register(A);
    expect(discharge.container.type_map, containsPair(A, isNotNull));

    discharge.container.register(C, named_constructor: "named", for_type: B);
    expect(discharge.container.type_map, containsPair(B, isNotNull));
  });

  test("Discharge container can resolve class without dependencies and empty constructor", () {
    Discharge discharge = new Discharge();
    discharge.container.register(E);
    expect(discharge.container.resolve(E) is E, isTrue);
  });

  test("Discharge container can resolve class with constructor containing named parameters with default value", () {
    Discharge discharge = new Discharge();
    discharge.container.register(A, named_constructor: "withNamedParameter");
    A a = discharge.container.resolve(A);
    expect(a.text, equals("default_named_param"));
  });

  test("Discharge container can resolve class with constructor containing positional parameters with default value", () {
    Discharge discharge = new Discharge();
    discharge.container.register(A);
    A a = discharge.container.resolve(A);
    expect(a.text, equals("default"));
  });

  test("Discharge container can resolve class with constructor containing named parameters with custom values", () {
    Discharge discharge = new Discharge();
    discharge.container.register(A, named_constructor: "withNamedParameter");
    A a = discharge.container.resolveWithArguments(A, {"text" : "a"});
    expect(a.text, equals("a"));
  });

  test("Discharge container can resolve class with constructor containing positional parameters with custom values", () {
    Discharge discharge = new Discharge();
    discharge.container.register(A);
    Map <String, Object> map = {"text":"a", "number":2};
    A a = discharge.container.resolveWithArguments(A, map);
    expect(a.text, equals("aa"));
  });

  test("Discharge container can resolve class dependencies", () {
    Discharge discharge = new Discharge();
    discharge.container.register(A);
    discharge.container.register(D);
    D d = discharge.container.resolve(D);
    expect(d.a.text, equals("default"));
  });

  test("Discharge container can resolve class dependencies with inhritance in mind", () {
    Discharge discharge = new Discharge();
    discharge.container.register(B);
    discharge.container.register(D);
    D d = discharge.container.resolve(D);
    expect(d.a.text, equals("inherited"));
  });

  test("Discharge container throws exception when trying to resolve unregistered class", () {
    Discharge discharge = new Discharge();
    expect(() => discharge.container.resolve(D), throws);
  });

  test("Discharge container throws exception when trying to resolve class with multiple subclasses registered", () {
    //i.e. B is A, C is A => resolve(D) => D(A) => Discharge does not know which one of A to instantiate
    Discharge discharge = new Discharge();
    discharge.container.register(C);
    discharge.container.register(B);
    discharge.container.register(D);
    expect(() => discharge.container.resolve(D), throws);
    discharge.container.register(A);
    expect(() => discharge.container.resolve(D), returnsNormally);
  });
}

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