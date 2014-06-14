part of service_container;

/**
 * All configuration of service required to instantiate it
 * 
 * Note that services are instantiated to be autowired by default
 */
class ServiceConfiguration {
  String _service_name;
  String _service_class;
  Map<String, ServiceArgument> _arguments;
  bool is_autowired;
  
  ServiceConfiguration(String this._service_name, this._service_class, this._arguments, {bool this.is_autowired:true});
  
  String get service_name => this._service_name;
  String get service_class => this._service_class;
  Map<String, ServiceArgument> get arguments => this._arguments;
  List<String> get dependencies {
    List<String> dependencies = new List<String>();
    
    this.arguments.forEach((name, argument) {
      if (argument is ServiceReferenceArgument && !argument.isSatisfied) {
        dependencies.add(argument.argument);
      }
    });
    
    return dependencies;
  }
}