part of di_container;

/**
 * Parent to [InstantiationInfo] and [ObjectReference], to allow storing both as resolution data in IoC
 */
abstract class ResolutionData {}

/**
 * Immutable representation of data required to instantiate a class 
 */
class InstantiationInfo extends ResolutionData {
  ClassMirror _class_mirror;
  Symbol _constructor;
  Map<String, Type> _positional_argument_types = new Map<String, Type>();
  Map<String, Type> _named_argument_types = new Map<String, Type>();
  Map<String, Object> _default_values  = new Map<String, Object>();
  
  InstantiationInfo(Type type, {named_constructor:""}) {
    this._class_mirror = reflectClass(type);
    this._constructor = new Symbol(named_constructor);
    
    var constructor_name = type.toString();
    if (named_constructor.isNotEmpty) {
      constructor_name = constructor_name + "." + named_constructor;
    }
    var constructor = new Symbol(constructor_name);
    var matched_constructors = reflectClass(type).declarations.values.where((DeclarationMirror mirror) {
      return (mirror is MethodMirror) && mirror.isConstructor && mirror.simpleName == constructor;
    });

    if (matched_constructors.isEmpty) {
      throw new ConstructorNotFoundException("The class " + type.toString() + " does not have constructor method: " + constructor);
    }

    matched_constructors.first.parameters.forEach((ParameterMirror argument) {
      var argument_name = MirrorSystem.getName(argument.simpleName);
      
      if (argument.hasDefaultValue) {
        this._default_values[argument_name] = argument.defaultValue.reflectee;
      }
      
      if (argument.isNamed) {
        this._named_argument_types[argument_name] = argument.type.reflectedType;
      } else {
        this._positional_argument_types[argument_name] = argument.type.reflectedType;
      }
    });
  }
  
  ClassMirror get class_mirror => this._class_mirror;
  Symbol get constructor => this._constructor;
  Map<String, Type> get positional_argument_types => this._positional_argument_types;
  Map<String, Type> get named_argument_types => this._named_argument_types;
  
  bool hasDefaultValueFor(String argument) {
    return this._default_values.containsKey(argument);
  }
  
  Object getDefaultValueFor(String argument) {
    if (! this.hasDefaultValueFor(argument)) {
      throw new NoDefaultArgumentValueException("No default value for argument: " + argument);
    }
    
    return this._default_values[argument];
  }
}

/**
 * Immutable representation of reference to object 
 */
class ObjectReference extends ResolutionData {
  var _object;
  ClassMirror _class_mirror;
  
  ObjectReference(this._object) {
    this._class_mirror = reflectClass(object.runtimeType);
  }
  
  ClassMirror get class_mirror => this._class_mirror;
  get object => this._object;
}