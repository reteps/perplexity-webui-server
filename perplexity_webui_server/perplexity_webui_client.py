from openai import OpenAI
import base64

client = OpenAI(base_url="http://localhost:8000/openai/v1", api_key="unused")


# chat_completion = client.chat.completions.create(
#     model="gpt-4o-mini",
#     messages=[
#         {
#             "role": "user",
#             "content": 'Say "This is a test"',
#         }
#     ],
# )
# print(chat_completion.choices[0].message.content)
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")


encoded_image = encode_image("cat.jpg")
# stream = client.chat.completions.create(
#     model="gpt-4",
#     messages=[{"role": "user", "content": "what is machine learning?"}],
#     stream=True,
# )

arg = [
    {
        "role": "user",
        "content": [
            {"type": "text", "text": "What's in this image?"},
            {
                "type": "image_url",
                "image_url": {"url": f"data:image/jpeg;base64,{encoded_image}"},
            },
        ],
    }
]
thread = client.beta.threads.create(messages=arg)

stream = client.beta.threads.runs.create(
    thread_id=thread.id,
    stream=True,
    model="gpt-4o",
    temperature=0,
    assistant_id="any",
)


for event in stream:
    if event.event == "thread.message.delta":
        print(event.data.delta.content[0].text.value)
