const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const app = express();
const port = 3000;

app.set('view engine', 'ejs');
app.use(express.static('public'));

app.use('/backend', createProxyMiddleware({
  target: 'http://localhost:8080/api',
  pathRewrite: { '^/backend': '' },
  changeOrigin: true,
}));

app.get('/', (req, res) => {
  res.render('booking');
});

app.listen(port, () => {
  console.log(`Frontend listening at http://localhost:${port}`);
});
