function fn() {    
  var env = karate.env; // get system property 'karate.env'
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
  } else if (env == 'stage') {
    config.faker = faker;
    // customize
    // e.g. config.foo = 'bar';
  } else if (env == 'e2e') {
    config.faker = faker;
    // customize
  }
  return config;
}