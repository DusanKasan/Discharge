part of service_container;

/**
 * This class provides configuration of services to [DependencyInjectionContainer]
 */
abstract class ServicesConfigurationProvider {
  Map<String, ServiceConfiguration> services_configurations = new Map<String, ServiceConfiguration>();
  
  void _registerServiceConfiguration(ServiceConfiguration config) {
    this.services_configurations[config.service_name] = config;
  }
    
  bool hasConfigFor(String service) {
    return this.services_configurations.containsKey(service);
  }
  
  ServiceConfiguration getConfigFor(String service) {
    if (!this.hasConfigFor(service)) {
      throw new NoServiceFoundException('No service with this name: ' + service);
    }
    
    return this.services_configurations[service];
  }
}

/**
 * Provides configuration of services by reading it from XML file.
 * 
 * The file must be like this:
 * <config>
 *  <services>
 *    <service name="{service_name}" class="{class_name}" {{autowire="yes"}}>
 *      <argument name="{argument_name}" {{type="service|int|bool|double"}}>{argument_value|service_name}</argument>
 *    </service>
 *  </services>
 * </config>
 * 
 * Where <service> and <argument> nodes can be 0 to n.
 * The notation {variable} means that it encloses variable. In XML ommit the braces.
 * The notation {{.......}} mean everything in it is optional.
 * todo: XML schema for config XML.
 * todo: multiple libraries same class name problem? test!
 * 
 * <service>:
 * If autowire is set to "yes" this service will be used in [DependencyInjectionContainer] as reference when resolving its type.
 * 
 * <argument>:
 * If you want to link services together, you specify argument type as "service" and then write its name.
 * 
 * Note that root <config> can have more children, this class only cares about the first <services> child.
 * This means, that you can use this file for all your configuration, not just for services.
 */
class ServicesConfigurationProviderXml extends ServicesConfigurationProvider {
  ServicesConfigurationProviderXml(File file) {
    var xml = parse(file.readAsStringSync()).children.first;     
    Iterable<XmlElement> services = xml.findElements('services').first.findElements('service');
    this._parseServices(services);
  }
  
  /**
   * Parses <service> nodes located in [services]
   */
  void _parseServices(Iterable<XmlElement> services) {
    services.forEach((XmlElement service_node) {
      String service_name = this._getRequiredAttribute(service_node, 'name');
      String service_class = this._getRequiredAttribute(service_node, 'class');
      
      var autowired_attribute = service_node.getAttribute('autowire');
      bool service_autowired = true;
      if (autowired_attribute != null && autowired_attribute == 'no') {
        service_autowired = false;
      }
      Iterable<XmlElement> arguments = service_node.findElements('argument');
      Map<String, ServiceArgument> service_arguments = this._parseArguments(arguments);
      
      var config = new ServiceConfiguration(service_name, service_class, service_arguments, is_autowired: service_autowired);      
      this._registerServiceConfiguration(config);
    });
  }
  
  /**
   * Helper method. Gets value of [attribute_name] from [node]
   */
  String _getRequiredAttribute(XmlElement node, String attribute_name) {
    String attribute = node.getAttribute(attribute_name);
    
    if (attribute == null) {
      throw new NoRequiredArgumentException('Required attribute $attribute_name not found');
    }
    
    return attribute;
  }
  
  /**
   * Parses <argument> nodes located in [arguments]
   */
  Map<String, ServiceArgument> _parseArguments(Iterable<XmlElement> arguments) {
    Map<String, ServiceArgument> arguments_map = new Map<String, ServiceArgument>();
    
    if (arguments == null) {
      return arguments_map;
    }
    
    arguments.forEach((XmlElement argument_node) {
      ServiceArgument argument;
      String argument_value = argument_node.text;
      String argument_name = argument_node.getAttribute('name');
      String argument_type = argument_node.getAttribute('type');

      if (argument_name == null) {
        throw new ServiceConfigurationException('Arguments must have name!');
      }
      
      
      if (argument_type == 'service') {
        argument = new ServiceReferenceArgument(argument_value);
      } else {
        //type conversions from String to other basic types
        var converted_argument_value = argument_value;
        
        if (argument_type == 'bool') {
          if (argument_value.toLowerCase() == "true") {
            converted_argument_value = true;  
          } else if (argument_value.toLowerCase() == "false") {
            converted_argument_value = false; 
          } else {
            throw new Exception("Unable to convert '$argument_value' to bool");
          }
        } else if (argument_type == 'int') {
          converted_argument_value = int.parse(argument_value);
        } else if (argument_type == 'double') {
          converted_argument_value = double.parse(argument_value);
        }
        
        argument = new ServiceArgument(converted_argument_value);
      }
      
      arguments_map[argument_name] = argument;
    });
    
    return arguments_map;
  }
}
