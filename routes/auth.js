const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('../db');
const router = express.Router();
const SECRET_KEY = 'your_secret_key'; // 環境変数推奨
const jwt = require('jsonwebtoken'); //トークン生成


//新規登録
router.post('/register', async (req, res) => {
  const { email, password, username } = req.body;
  if (!email || !password || !username) {
    return res.status(400).json({ error: '全項目必須です' });
  }

  try {
    const existingUser = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'このメールアドレスは既に登録されています' });
    }

    console.log('新規登録処理開始');

    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('ハッシュ化完了');

    await pool.query(
      'INSERT INTO users (username, email, password) VALUES ($1, $2, $3)',
      [username, email, hashedPassword]
    );
    console.log('データベースに挿入完了');
    res.status(201).json({ message: '登録成功' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'サーバーエラー' });
  }
});

//ログイン
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // 該当メールのユーザーを探す
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user) {
      return res.status(401).json({ error: 'メールが存在しません' });
    }

    // パスワード検証
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'パスワードが違います' });
    }

    // トークン生成
    const token = jwt.sign(
      { id: user.id, username: user.username },
      SECRET_KEY,
      { expiresIn: '7d' }
    );

    // トークン返却
    res.status(200).json({ message: 'ログイン成功', token, username: user.username });

  } catch (err) {
    console.error('ログインエラー:', err);
    res.status(500).json({ error: 'サーバーエラー' });
  }
});


//トークン確認の中間処理
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'トークンが必要です' });

  const token = authHeader.split(' ')[1]; // "Bearer token"
  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    req.user = decoded; // 次で使える
    next();
  } catch (err) {
    return res.status(403).json({ error: 'トークン無効または期限切れ' });
  }
}

router.get('/protected', verifyToken, (req, res) => {
  // verifyToken ミドルウェアでトークンが有効か確認済み
  res.status(200).json({ message: '認証済みユーザー', user: req.user });
})

router.get('/test', (req, res) => {
  res.send('✅ Server is working');
});


module.exports = { router, verifyToken };