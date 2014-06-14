part of service_container;

class BaseServiceContainerException implements Exception{
  String cause;
  
  BaseServiceContainerException(this.cause);
}

class NoServiceFoundException extends BaseServiceContainerException {
  NoServiceFoundException(cause) : super(cause);
}

class NoRequiredArgumentException extends BaseServiceContainerException {
  NoRequiredArgumentException(cause) : super(cause);
}

/**
 * This gets thrown when there are multiple classes with the same name (with different libraries) registered in [DependencyInjectionContainer]
 */
class MultipleTypesSameNameException extends BaseServiceContainerException {
  MultipleTypesSameNameException(cause) : super(cause);
}

class ServiceConfigurationException extends BaseServiceContainerException {
  ServiceConfigurationException(cause) : super(cause);
}

class ServiceNotFoundException extends BaseServiceContainerException {
  ServiceNotFoundException(cause) : super(cause);
}

class UnableToSatisfyDependenciesException extends BaseServiceContainerException {
  UnableToSatisfyDependenciesException(cause) : super(cause);
}