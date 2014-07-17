import "package:discharge/discharge.dart";
import "package:unittest/unittest.dart";

void main() {
  test("Discharge instantiation", () {
    var discharge = new Discharge();
    expect(discharge is Discharge, isTrue);
    expect(discharge.container, isNotNull);
    expect(discharge.services, isNotNull);
  });

  test("StaticDischarge initialization", () {
    StaticDischarge.init();

    expect(StaticDischarge.container, isNotNull);
    expect(StaticDischarge.services, isNotNull);
  });


  test("StaticDischarge generic instantiation", () {
    var discharge = new StaticDischarge<A>();
    expect(discharge is StaticDischarge, isTrue);
  });
}

