import os
from huggingface_hub import InferenceClient

with open('hfapikey.txt', 'r') as f:
    api_key = f.read().strip() 

client = InferenceClient(api_key=api_key)

image = client.text_to_image(
    prompt="A serene lake surrounded by mountains at sunset, photorealistic style",
    model="black-forest-labs/FLUX.1-dev"
)

# Save the generated image
image.save("generated_image.png")

