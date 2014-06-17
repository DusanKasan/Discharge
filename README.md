#Discharge - Dependency injection and service container for Dart
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

##Discharge services container - coming soon