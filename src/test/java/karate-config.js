function fn() {    
  var env = karate.env; // get system property 'karate.env'
  var locale = Java.type('java.util.Locale')
  var faker = Java.type('com.github.javafaker.Faker');


  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
	myVarName: 'someValue'
  };
  if (env == 'dev'){
    config.faker = faker;
    config.locale = locale;
  } else if (env == 'stage') {
    config.faker = faker;
    config.locale = locale;
    // customize
    // e.g. config.foo = 'bar';
  } else if (env == 'e2e') {
    config.faker = faker;
    config.locale = locale;
    // customize
  }
  return config;
}