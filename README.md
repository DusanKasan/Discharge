#Discharge - Dependency injection and service container for Dart
[![Build Status](https://drone.io/github.com/DusanKasan/Discharge/status.png)](https://drone.io/github.com/DusanKasan/Discharge/latest)

Discharge is dependency injection (DI) and service container that uses constructor DI. 

This means that as long as Discharge DI container knows about your classes, you no longer need to care about any of the dependencies between them. Discharge will help you to embrace DI without all the additional code that stems from the need to instantiate all the dependencies outside the classes which will use them. This will in turn allow you to loosen the coupling between classes in your application which means better code quality, smaller classes, testable code and more :) 

Its service container provides means to configure and store instances and define dependencies by using outside-the-code configuration. These instances are each assigned unique identifier (chosen by user) and can be accessed anytime after the initial configuration.

##Example classes
In every example code snippet, as well as in text, we will refer to these classes and their implementation.
````dart
class A {
    String text;
    A([this.text = "default"]);
}

class B extends A {
    B() : super("b_inherit");
}

class C extends A {
    C() : super("c_inherit");
}

class Y {
    A a;
    Z(this.a, [String additional = ""]) {
        this.a += additional;
    }
    String getText() => this.a.text;
}

class Z {
    A a;
    Z(this.a);
    String getText() => this.a.text;
}
````

##Discharge dependency injection container
Discharge DI container is simple DI container that uses constructor DI to achieve automation. To use it, you have to register a class or instance into it. Then when you need object of a class that has all its dependencies registered in DI container, you can ask the container to create it for you, effectively resolving any dependencies.

When registering classes, you always have to remember that even though Discharge DI container will do its best to guess which class to instantiate, it can not read your mind. So imagine the following scenario, if you register only B and C to the container and then ask it to instantiate object of class A, it will correctly identify B and C as viable targets to instantiate, but there is no way to choose between the two, so an `MultipleSubclassesRegisteredException` will be thrown.

The Discharge DI container can be accessed as `container` property of `Discharge` class.

####Registering classes into Discharge DI container
When you register a class into Discharge DI container, you are basically telling the container that: "When an object of this class is requested, instantiate like this.". To register a class you must call `void register(Type type, {String named_constructor: "", Type for_type:null})`. If you only supply `type`, the default constructor will be used when instantiating. The argument `named_constructor` is pretty self-explanatory, it will use the specified named constructor for instantiation. You can also register type as any of its super-types using `for_type` argument. 
Example:
````dart
var discharge = new Discharge();
discharge.container.register(A); //uses default constructor to instantiate object of class A
discharge.container.register(B, named_constructor: "differentConstructor") //uses named constructor B.different constructor to instantiate object of class B
````

####Registering objects into Discharge DI container
When you register object into the container, instead of instantiating objects of that class, Discharge will always return that object when resolving dependencies will require object of its class. To register an object, you must call `void registerInstance(Object object, {Type for_type:null})` method, where `object` is the object that will represent its class in the container. You can also register object as any of its super-types using `for_type` argument. 
Example:
````dart
var discharge = new Discharge();
var a_instance = new A();
discharge.container.registerInstance(a_instance); //when resolving class A, a_instance will be returned
````

####Resolving dependencies
When you want Discharge DI container to resolve class dependencies for you, you just need to call the `Object resolve(Type type)` method. It will automatically resolve all dependencies along the dependency tree and returns `Object` of the desired `type`.
Example:
````dart
var discharge = new Discharge();
discharge.container.register(A); //will instantiate A() => A().text = "default"
discharge.container.register(Z); //will inject A automatically
Z z_instance = discharge.container.resolve(Z); //resolved object of class Z
String text = z_instance.getText(); //text = "default"
````

####Resolving dependencies with some manually set arguments
But what if you want to resolve the dependencies automatically, but set some arguments manually? You can call the `Object resolveWithArguments(Type type, Map<String,Object> arguments)` method. It works just like the `resolve` method, except if does not resolve arguments that are contained in `arguments` argument. This behavior is used when instantiating services.
Example:
````dart
var discharge = new Discharge();
discharge.container.register(A); //will instantiate A() => A().text = "default"
discharge.container.register(Y); //will inject A automatically
Z z_instance = discharge.container.resolveWithArguments(Y, {"additional": "NOT"});
String text = z_instance.getText(); //text = "defaultNOT"
````

##Discharge service container
Discharge service container stores and configures objects (called services) of arbitrary class. It utilizes Discharge DI container to resolve dependencies between classes and XML file to store the user-defined configuration. Each service is defined by its name - unique string identification chosen by user. The main focus of Discharge service container is to work together with Discharge DI container and allow all object configuration to be outside the code and resolving dependencies automatically.

For example, there is no need to configure database access or logger in the code. Discharge will handle the dependencies and configuration before you ever need it. Another advantage is, you can seamlessly change logic or configuration behind each service and the rest of your application will never know.

The service container provides the tools to register services from inside the code with the `void registerService(String name, Object service)` method, but outside-of-code configuration is preferred.

Discharge service container can be accessed as `services` property of `Discharge` class.

####Registering service
The method `void registerService(String name, Object service)` will register service `service` with name `name` to Discharge service container.
Example:
````dart
var discharge = new Discharge();
discharge.services.registerService("service_a", new A()); //will create new service named "service_a" by instantiating A
````

####Unregistering service
The method `void unregisterService(String name)` will remove service `service` with name `name` from Discharge service container.
Example:
````dart
var discharge = new Discharge();
discharge.services.registerService("service_a", new A()); //will create new service named "service_a" by instantiating A
discharge.services.unregisterService("service_a"); //removes "service_a" from service container
````

####Checking if service exists
You can check if service is registered by calling `bool hasService(String name)`
Example:
````dart
var discharge = new Discharge();
discharge.services.registerService("service_a", new A()); //will create new service named "service_a" by instantiating A
discharge.services.hasService("service_a"); //true
````

####Retrieving service
To retrieve service from the container, you call `Object getService(String name)` which will return the service if it is registered. If it's not registered it will throw an exception.
Example:
````dart
var discharge = new Discharge();
discharge.services.registerService("service_a", new A()); //will create new service named "service_a" by instantiating A
var service = discharge.services.getService("service_a"); //fetches "service_a" from service container
````

####Configuring services
Service configuration is done through `void configureServices(ServicesConfigurationProvider configuration_provider)` method. There is currently only one implementation of `ServicesConfigurationProvider` available. `ServicesConfigurationProviderXml` will read the XML file you pass into its constructor.
Here is an example of the configuration file:
````xml
<config>
<services>
  <service name="service_a" class="A" autowire="yes"> <!-- Create service "service_a" by instantiating object of class A, then autowires it to DI container. -->
      <argument name="text">po</argument> <!-- Argument with name "text" equals "po". Argument type is omitted so defaults to string. -->
      <argument name="number" type="int">2</argument> <!-- Argument with name "text" equals "po". Argument type is integer. -->
  </service>

  <service name="service_d" class="D"> <!-- Create service "service_d" by instantiating object of class D, do not autowire. -->
      <argument name="a" type="service">service_a</argument> <!-- Argument with name "a" references service "service_a" -->
  </service>
</services>
</config>
````

The schema for the config file can be found in tests directory. Following is just a short explanation and meaning of used tags/arguments:
- The root element name does not matter but it must have first-level child named `<services>`
- `<services>` have children named `<service>`. Each service element represents 1 service.
- `<service>` can have following attributes
    - name : name of the service
    - class : class to instantiate (note that the constructor registered in DI container will be used)
    - autowire : yes/no, optional parameter - no by default. If set to "yes", the service will be registered into DI container for its class.
- `<service>` have children named `<argument>`, representing constructor arguments. You can omit arguments that have default values if you wish. It encloses argument value.
- `<argument>` can have following attributes
    - name : argument name, for example in constructor of `A`, there is 1 argument called `text`
    - type : bool/int/double/string/service, optional parameter - defines what data type is the argument. Default value is "string". If type is set to "service", the value of `<argument>` is the service name.
    
Please note that Discharge service container is bound to its DI container, meaning when instantiating services, it actually uses DI container to instantiate. From this stems the fact, that it uses the constructor with which was the class registered into DI container. On the other hand, it allows for autowiring - registering services as representations of their class into DI container.

Example:
````dart
var discharge = new Discharge();
var config = new File("path/to/file.xml");
var config_provider = new ServicesConfigurationProviderXml(config);
discharge.service.configureServices(config_provider); //will instantiate services according to config file
````