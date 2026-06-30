import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const GEMINI_KEY = Deno.env.get("GEMINI_API_KEY")

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 })
  try {
    const { prompt } = await req.json()
    if (!prompt) return new Response(JSON.stringify({ error: "Missing prompt" }), { status: 400 })

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=${GEMINI_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { responseModalities: ["Text", "Image"] }
        })
      }
    )
    const data = await response.json()
    const parts = data?.candidates?.[0]?.content?.parts ?? []
    let imageBase64 = null
    for (const part of parts) {
      if (part.inlineData) {
        imageBase64 = part.inlineData.data
        break
      }
    }

    return new Response(JSON.stringify({ imageBase64, text: parts?.[0]?.text ?? null }), {
      headers: { "Content-Type": "application/json" }
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 })
  }
})
