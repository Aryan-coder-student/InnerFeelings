import os
from huggingface_hub import InferenceClient

client = InferenceClient(api_key="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")

image = client.text_to_image(
    prompt="A serene lake surrounded by mountains at sunset, photorealistic style",
    model="black-forest-labs/FLUX.1-dev"
)

# Save the generated image
image.save("generated_image.png")

