part of service_container;

/**
 * Immutable representation for service argument
 */
class ServiceArgument {
  var _argument;
  
  ServiceArgument(this._argument);
  
  get argument => this._argument;
}

/**
 * Immutable representation for service argument, which references another service 
 */
class ServiceReferenceArgument extends ServiceArgument {
  bool isSatisfied = false;
  
  ServiceReferenceArgument(String argument) : super(argument);
  
  /**
   * Satisfy this argument with [service] object
   */
  void satisfyWith(service) {
    this._argument = service;
    this.isSatisfied = true;
  }
}