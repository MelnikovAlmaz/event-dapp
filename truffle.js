module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
};

// берём Express
var express = require('express');

// создаём Express-приложение
var app = express();

// создаём маршрут для главной страницы
// http://localhost:8080/
app.get('/', function(req, res) {
  res.sendfile('src/index.html');
});

// запускаем сервер на порту 8080
app.listen(8485);
// отправляем сообщение
console.log('Сервер стартовал!');
