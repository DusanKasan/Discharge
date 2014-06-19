library discharge;

import "src/di_container/di_container.dart";
import "src/service_container/service_container.dart";

export "src/service_container/service_container.dart";
export "src/di_container/di_container.dart";

/**
 * Dependency injection and service container for Dart.
 */
class Discharge {
  DependencyInjectionContainer _di_container;
  ServiceContainer _service_container;
  
  Discharge() {
    this._di_container = new DependencyInjectionContainer(); 
    this._service_container = new ServiceContainer(this.container); 
  }
  
  DependencyInjectionContainer get container => this._di_container;
  ServiceContainer get services => this._service_container;
}

/**
 * Dependency injection and service container for Dart. With resolving type hints.
 */
class StaticDischarge<E> {
  static DependencyInjectionContainer _di_container;
  static ServiceContainer _service_container;
  
  static void init() {
    _di_container = new DependencyInjectionContainer(); 
    _service_container = new ServiceContainer(_di_container); 
  }
  
  static DependencyInjectionContainer get container => _di_container;
  static ServiceContainer get services => _service_container;
 
  E resolve() {
    return _di_container.resolve(E);
  }
}