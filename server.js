const express = require('express');
const cors = require('cors');
const app = express();
const { router: authRoutes, verifyToken } = require('./routes/auth');


app.use(cors({
  origin: 'https://imaginative-nasturtium-4f85bc.netlify.app'
}));
app.use(express.json());
app.use(authRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT,'0.0.0.0', () => {
  console.log(`✅ サーバー起動中 http://localhost:${PORT}`);
});




//const express = require('express');
//const cors = require('cors');
//const bodyParser = require('body-parser');
//const mysql = require('mysql2');
//
//const app = express();
//const PORT = 3000;
//
////ハッシュ化
//const bcrypt = require('bcrypt');
//const saltRounds = 10; // ハッシュの強度
//
//// Middlewares
//app.use(cors());
//app.use(bodyParser.json());
//
//// MySQL接続設定
//const db = mysql.createConnection({
//  host: 'localhost',
//  user: 'root',
//  password: 'root',
//  database: 'chat_app_db',
//  port: 8889
//});
//
//// MySQL接続後にサーバー起動
//db.connect((err) => {
//  if (err) {
//    console.error('MySQL接続失敗:', err);
//    return;
//  }
//
//  console.log('MySQL接続成功');
//
//  // 登録処理
//  app.post('/register', async (req, res) => {
//    const { email, password, username } = req.body;
//
//    if (!email || !password || !username) {
//      return res.status(400).json({ error: '全ての項目を入力してください' });
//    }
//
//    try {
//      const hashedPassword = await bcrypt.hash(password, saltRounds);
//
//      const sql = 'INSERT INTO users (username, email, password) VALUES (?, ?, ?)';
//      const values = [username, email, hashedPassword];
//
//      db.query(sql, values, (err, result) => {
//        if (err) {
//          console.error('データ挿入失敗:', err);
//          return res.status(500).json({ error: 'サーバーエラー' });
//        }
//
//        console.log('入力パス:', password);
//        console.log('ハッシュ化後:', hashedPassword);
//        console.log('登録ユーザー:', { email, username });
//        res.status(201).json({ message: '登録成功！' });
//      });
//    } catch (err) {
//      console.error('ハッシュ化失敗:', err);
//      res.status(500).json({ error: 'ハッシュ化エラー' });
//    }
//  });
//
//
////ログイン処理
//app.post('/login', (req, res) => {
//  const { email, password } = req.body;
//
//  const sql = 'SELECT * FROM users WHERE email = ?';
//  db.query(sql, [email], async (err, results) => {
//    if (err) {
//      console.error('ログインクエリ失敗:', err);
//      return res.status(500).json({ error: 'サーバーエラー' });
//    }
//
//    if (results.length === 0) {
//      return res.status(401).json({ error: 'メールが存在しません' });
//    }
//
//    const user = results[0];
//
//    const isMatch = await bcrypt.compare(password, user.password);
//    if (!isMatch) {
//      return res.status(401).json({ error: 'パスワードが違います' });
//    }
//
//    res.status(200).json({ message: 'ログイン成功', username: user.username });
//  });
//});
//
//
//  // サーバー起動
//  app.listen(PORT, () => {
//    console.log(`✅ サーバー起動中: http://localhost:${PORT}`);
//  });
//});
