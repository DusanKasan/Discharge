part of di_container;

class BaseDepenedencyInjectionContainerException implements Exception{
  String cause;
  
  BaseDepenedencyInjectionContainerException(this.cause);
}

class NoSuitableTypeRegisteredException extends BaseDepenedencyInjectionContainerException {
  NoSuitableTypeRegisteredException(cause) : super(cause);
}

class InstantiationInfoEpected extends BaseDepenedencyInjectionContainerException {
  InstantiationInfoEpected(cause) : super(cause);
}

class TypeResolutionException extends BaseDepenedencyInjectionContainerException {
  TypeResolutionException(cause) : super(cause);
}

class ArgumentResolutionException extends BaseDepenedencyInjectionContainerException {
  ArgumentResolutionException(cause) : super(cause);
}

class NoDefaultArgumentValueException extends BaseDepenedencyInjectionContainerException {
  NoDefaultArgumentValueException(cause) : super(cause);
}

class ConstructorNotFoundException extends BaseDepenedencyInjectionContainerException {
  ConstructorNotFoundException(cause) : super(cause);
}