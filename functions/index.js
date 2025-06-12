const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { OpenAI } = require("openai");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

//  シークレットの参照
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

exports.chatWithAI = onRequest(
  {
    region: "us-central1",
    memory: "256MiB",
    timeoutSeconds: 60,
    secrets: [OPENAI_API_KEY], // ← ここが重要！
  },
  async (req, res) => {
    const messages = req.body.messages;

    const openai = new OpenAI({
      apiKey: OPENAI_API_KEY.value(), // ← こうやって値を取得する
    });

    try {
          const response = await openai.chat.completions.create({
            model: "gpt-3.5-turbo",
            messages: messages,
          });

      console.log("OpenAI full response:", JSON.stringify(response, null, 2));

      res.status(200).json({ reply: response.choices[0].message.content });
    } catch (error) {
      console.error("OpenAI API Error:", error.message);
      res.status(500).json({ error: "AI応答エラー: " + error.message });
    }
  }
);