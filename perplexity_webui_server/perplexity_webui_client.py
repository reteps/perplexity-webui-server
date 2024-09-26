from openai import OpenAI

openai_client = OpenAI(
    base_url="http://localhost:8000/openai/v1",
    api_key="unused"
)

chat_completion = openai_client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {
            "role": "user",
            "content": 'Say "This is a test"',
        }
    ],
)
print(chat_completion.choices[0].message.content)