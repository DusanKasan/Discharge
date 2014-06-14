library service_container;

import '../di_container/di_container.dart';
import 'dart:mirrors';
import 'dart:io';
import 'package:xml/xml.dart';

part 'exceptions.dart';
part 'service_argument.dart';
part 'service_configuration.dart';
part 'service_configuration_provider.dart';

/**
 * Simple container for services
 * 
 * todo: iterable, map
 */
class ServiceContainer {
  Map<String, Object> _services = new Map<String, Object>();
  DependencyInjectionContainer _di_container;
  
  ServiceContainer(DependencyInjectionContainer this._di_container);
  
  void configureServices(ServicesConfigurationProvider configuration_provider) {
    configuration_provider.services_configurations.forEach((service_name, config) {
      this._resolveService(service_name, configuration_provider);
    });
  }
  
  /**
   * Resolves [service] from [configuration_provider] and all its dependencies.
   */
  void _resolveService(String service, ServicesConfigurationProvider configuration_provider) {
    ServiceConfiguration service_config = configuration_provider.getConfigFor(service);
    Map<String, Object> arguments = new Map<String, Object>();
      
    if (this.hasService(service)) {
      return;
    }
    
    service_config.arguments.forEach((name, argument) {
      if (argument is ServiceReferenceArgument && !argument.isSatisfied) {
        this._resolveService(argument.argument, configuration_provider);
      }
      
    });
      
    this._satisfy(service_config);
    
    service_config.arguments.forEach((name, argument) {
      arguments[name] = argument.argument;
    });

    var service_class = this._getInstantiationInfoForTypeName(service_config.service_class).class_mirror.reflectedType;    
    var service_object = this._di_container.resolveWithArguments(service_class, arguments);
    
    if (service_config.is_autowired) {      
      this._di_container.registerInstance(service_object);
    }
    
    this.registerService(service, service_object);
  }
  
  /**
   * Get instantiation info for [type_name] registered
   * . Only matches if [Type] has name == [type_name]. No type juggling.
   * 
   * This method is used when resolving services and should be removed when the Mirrors will get better.
   * I just solves the problem of creating [Type] from [String]. At the moment, one have to iterate through
   * every class in every accessible library - which is not ideal and is error prone.
   * 
   * todo: remove/refactor when something like this is supported new Type(library, name)
   */
  InstantiationInfo _getInstantiationInfoForTypeName(String type_name) {
    ResolutionData info;
    
    this._di_container.type_map.forEach((type, resolution_data) {
      if (MirrorSystem.getName(reflectType(type).simpleName) == type_name) {
        info = resolution_data;
      }
    });
    
    if (info == null) {
      throw new NoSuitableTypeRegisteredException('Unable to get resolution data for ' + type_name);
    } else if (info is ObjectReference) {
      throw new InstantiationInfoEpected('Service can not be instantiated. Object registered instead of instantiation info.');
    }
    
    return info;
  }
  
  /**
   * Tests if there is instantiation info for [type_name] registered. 
   * Only matches if [Type] has name == [type_name]. No type juggling.
   * 
   * This method is used when resolving services and should be removed when the Mirrors will get better.
   * I just solves the problem of creating [Type] from [String]. At the moment, one have to iterate through
   * every class in every accessible library - which is not ideal and is error prone.
   * 
   * todo: remove/refactor when something like this is supported new Type(library, name)
   */
  bool _hasInstantiationInfoForTypeName(String type_name) {
    bool has_resolution_data = false;
    
    try {
      this._getInstantiationInfoForTypeName(type_name); //throws NoSuitableTypeRegisteredException
      return true;
    } on NoSuitableTypeRegisteredException catch (exception) {
      return false;
    } on InstantiationInfoEpected catch (exception) {
      return false;
    }
    
    return has_resolution_data;
  }
  
  void registerService(String name, Object service) {
    this._services[name] = service;
  }
  
  bool hasService(String name) {
    return  this._services.containsKey(name);
  }
  
  Object getService(String name) {
    if (!this.hasService(name)) {
      throw new ServiceNotFoundException('Service with this name is not registered: ' + name);
    }
    
    return this._services[name];
  }
  
  Object unregisterService(String name) {
    if (!this.hasService(name)) {
      throw new ServiceNotFoundException('Service with this name is not registered: ' + name);
    }
    
    return this._services.remove(name);
  }
  
  //are all needed services registered?
  bool _canSatisfy(ServiceConfiguration config) {
    config.dependencies.forEach((service) {
      if (!this.hasService(service)) {
        return false;
      }
    });
    
    return true;    
  }
  
  void _satisfy(ServiceConfiguration config) {
    if (!this._canSatisfy(config)) {
      throw new UnableToSatisfyDependenciesException('Service container can not satisfy the needs of service: ' + config.service_name);
    }
    
    config.arguments.forEach((name, argument) {
      if (argument is ServiceReferenceArgument && !argument.isSatisfied) {        
        var service = this.getService(argument.argument);
        argument.satisfyWith(service);
      }
    });
  }
}
