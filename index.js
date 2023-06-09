var express = require('express');
var app = express();


const { tasks } = require('./handlers/tasks');
app.get('/tasks', tasks);


const PORT = process.env.PORT || 5050;

app.get('/', (req, res) => {
  res.send('This is my demo project');
});

app.listen(PORT, function () {
  console.log(`Demo project at: ${PORT}!`);
});
