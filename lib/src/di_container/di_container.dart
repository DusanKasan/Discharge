library di_container;

import 'dart:mirrors';

part 'exceptions.dart';
part 'resolution_data.dart';

/**
 * Inversion of Control container. 
 * Main features:
 * - Type matching, if trying to resolve unregistered type, its subtype will be instantiated instead (if there is only one subtype. Otherwise will throw.)
 * - Automatized dependency injection, if all classes in command chain are registered, the dependencies will resolve automatically
 * - Can register objects to autowire them to dependent classes instead of creating new instances on the fly.
 */
class DependencyInjectionContainer {
  Map<Type, ResolutionData> type_map = new Map<Type, ResolutionData>();

  /**
   * Registers [type], optionally with [named_constructor] to [DependencyInjectionContainer].
   * 
   * Whenever resolving [type], using [DependencyInjectionContainer] (either directly or as dependency), this will be used to instantiate.
   */
  void register(Type type, {String named_constructor: "", Type for_type:null}) {
    var register_as = type;
    
    if (for_type != null) {
      register_as = for_type;
    }
    
    type_map[register_as] = new InstantiationInfo(type, named_constructor: named_constructor);
  }
  
  /**
   * Instead of instantiating new class when resolving this [object]s class,
   * always return this instance of [object]. 
   */
  void registerInstance(Object object, {Type for_type:null}) {
    Type type;
    
    if (for_type == null) {
      type = reflectType(object.runtimeType).reflectedType;
    } else {
      type = for_type.runtimeType;
    }
    
    this.type_map[type] = new ObjectReference(object);
  }

  /**
   * Instantiates [type].
   * 
   * Dependencies are satisfied using type matching between registered types.  
   */
  Object resolve(Type type) {
    var positional_arguments = new List();
    var named_arguments = new Map();
    ResolutionData resolution_data = this._getResolutionDataFor(type);
    var instance;
    
    if (resolution_data is ObjectReference) {
      instance = resolution_data.object;
    } else if (resolution_data is InstantiationInfo) {      
      resolution_data.positional_argument_types.forEach((name, argument_type) {
        var resolved_argument = this._resolve_argument(name, argument_type, resolution_data);
        positional_arguments.add(resolved_argument);
     });
    
      resolution_data.named_argument_types.forEach((name, argument_type) {
        var resolved_argument = this._resolve_argument(name, argument_type, resolution_data);     
        named_arguments[name] = resolved_argument;
      });
    
      instance = resolution_data._class_mirror.newInstance(resolution_data.constructor, positional_arguments, named_arguments).reflectee;
    }
    
    return instance;
  }
  
  /**
   * Instantiates [type], with [arguments].
   * 
   * Note that not all arguments required for instantiation of [type] have to be passed.
   * The missing arguments will be satisfied by [DependencyInjectionContainer] if possible. 
   */
  Object resolveWithArguments(Type type, Map<String,Object> arguments) {
    var positional_arguments = new List();
    var named_arguments = new Map();
    ResolutionData resolution_data = this._getResolutionDataFor(type);
    var instance;

    if (resolution_data is ObjectReference) {
      instance = resolution_data.object;
    } else if (resolution_data is InstantiationInfo) {
      resolution_data.positional_argument_types.forEach((name, argument_type) {      
        if (arguments.containsKey(name)) {
          positional_arguments.add(arguments[name]);
        } else {
          var resolved_argument = this._resolve_argument(name, argument_type, resolution_data);
          positional_arguments.add(resolved_argument);
        }
      });
    
      resolution_data.named_argument_types.forEach((name, argument_type) {
        String string_name = name.toString();
        
        if (arguments.containsKey(name)) {
          named_arguments[name] = arguments[name];
        } else {
         var resolved_argument = this._resolve_argument(name, argument_type, resolution_data);
         named_arguments[name] = resolved_argument;
        }
      });
    
      instance = resolution_data._class_mirror.newInstance(resolution_data.constructor, positional_arguments, named_arguments).reflectee;
    }
    
    return instance;
  }    
  
  /**
   * Get correct [InstantiationInfo] for [type]
   * 
   * Firstly, try to find [type] explicitly, then if it is not found, search for subtype.
   * If there are multiple subtypes of [type] registered, throws exception.
   * 
   * todo: exception type 
   */
  ResolutionData _getResolutionDataFor(Type type) {
    ResolutionData info = null;
    
    if (this.type_map.containsKey(type)) {
      info = this.type_map[type];
    } else {
      var class_mirror = reflectClass(type);
      
      this.type_map.values.forEach((inst_info) {
        if (inst_info.class_mirror.isSubclassOf(class_mirror)) {
          if (info != null) {
            throw new TypeResolutionException('Multiple subclasses of ' + type.toString() + ' found in container');
          } else {
            info = inst_info;
          }
        }
      });
    }
    
    if (info == null) {
      throw new NoSuitableTypeRegisteredException('Unable to get resolution data for ' + type.toString());
    }
    
    return info;
  }
  
  /**
   * Tests if [DependencyInjectionContainer] has resolution data for type (or one of its subclasses).
   */
  bool _hasResolutionDataFor(Type type) {
    bool has_resolution_data = false;
    
    try {
      this._getResolutionDataFor(type); //throws NoSuitableTypeRegisteredException
      return true;
    } on NoSuitableTypeRegisteredException catch (exception) {
      return false;
    }
    
    return has_resolution_data;
  }
  
  /**
   * Resolves argument when instantiating class.
   * 
   * Firstly tries to resolve [type] of the argument.
   * If there is no suitable type registered, it will check, if there is default value for this argument in constructor.
   * If both of these are false, then throws [Exception]
   */
  Object _resolve_argument(String name, Type type, InstantiationInfo instantiation_info) {
    var resolved_object;
                    
    if (this._hasResolutionDataFor(type)) {
      resolved_object = this.resolve(type);
    } else if (instantiation_info.hasDefaultValueFor(name)) {
      resolved_object = instantiation_info.getDefaultValueFor(name);
    } else {
      throw new ArgumentResolutionException("Unable to find value for argument: " + name);
    }
    
    return resolved_object;
  }
}


