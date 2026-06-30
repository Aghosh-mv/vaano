import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const GEMINI_KEY = Deno.env.get("GEMINI_API_KEY")

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 })
  try {
    const { prompt } = await req.json()
    if (!prompt) return new Response(JSON.stringify({ error: "Missing prompt" }), { status: 400 })

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: `Generate captions for: ${prompt}` }] }]
        })
      }
    )
    const data = await response.json()
    const text = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "No captions generated"

    return new Response(JSON.stringify({ captions: text }), {
      headers: { "Content-Type": "application/json" }
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 })
  }
})
