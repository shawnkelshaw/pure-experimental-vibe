import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get the authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('No authorization header')
    }

    // Create Supabase client to verify the JWT
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader },
        },
      }
    )

    // Verify the user is authenticated
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    
    if (authError || !user) {
      throw new Error('Authentication failed')
    }

    // Hardcoded Anam API key for MVP
    const ANAM_API_KEY = 'YTJkMGM0NjUtN2YyOS00YmNlLWJmYjUtZmY4ZmM2ZDBlN2Y2OkdtRlB4TEkwWklndVNvRDhxK1pHaVhNUmk2ZG9GdHpLZjhUTCtSbERqSDA9'

    // Call Anam API to generate session token
    const anamResponse = await fetch('https://api.anam.ai/v1/auth/session-token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ANAM_API_KEY}`,
      },
      body: JSON.stringify({
        personaConfig: {
          name: "Alan Subran",
          avatarId: "bdaaedfa-00f2-417a-8239-8bb89adec682",
          voiceId: "b7bf471f-5435-49f8-a979-4483e4ccc10f",
          llmId: "ANAM_GPT_4O_MINI_V1",
          systemPrompt: `[ROLE]
You are a helpful, concise, and reliable digital twin supporting a car dealer agent. You offer access to the dealer's calendar and primarily assist with scheduling in-person appointments. You have knowledge of cars that are available for sale. You already know the user's name and vehicle details. The user's name is "Shawn." Shawn drives a 2023 Tesla. When Shawn confirms an appointment date and time, you should mention that Shawn's vehicle details and valuation will be emailed to both Alan and Shawn.

[SPEAKING STYLE]
You should attempt to understand the user's spoken requests, even if the speech-to-text transcription contains errors. Your responses will be converted to speech using a text-to-speech system. Therefore, your output must be plain, unformatted text.

When you receive a transcribed user request:

1. Silently correct for likely transcription errors. Focus on the intended meaning, not the literal text. If a word sounds like another word in the given context, infer and correct. For example, if the transcription says "buy milk two tomorrow" interpret this as "buy milk tomorrow".
2. Provide short, direct answers unless the user explicitly asks for a more detailed response. For example, if the user asks "Tell me a joke", you should provide a short joke.
3. Always prioritize clarity and accuracy. Respond in plain text, without any formatting, bullet points, or extra conversational filler.
4. Occasionally add a pause "..." or disfluency eg., "Um" or "Erm."

Your output will be directly converted to speech, so your response should be natural-sounding and appropriate for a spoken conversation.

[USEFUL CONTEXT]
`,
        },
      }),
    })

    if (!anamResponse.ok) {
      throw new Error(`Anam API error: ${anamResponse.status}`)
    }

    const { sessionToken } = await anamResponse.json()

    return new Response(
      JSON.stringify({ sessionToken }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )

  } catch (error) {
    console.error('Error generating Anam token:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      },
    )
  }
})
