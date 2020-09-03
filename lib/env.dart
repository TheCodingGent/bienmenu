const bool isProduction = bool.fromEnvironment('dart.vm.product');

const devConfig = {'API_URL': 'http://localhost:5000/'};

const productionConfig = {
  'API_URL': 'https://cryptic-dawn-36054.herokuapp.com/'
};

final environment = isProduction ? productionConfig : devConfig;
