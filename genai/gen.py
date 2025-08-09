import os
import time
import base64
import PIL.Image
from PIL import Image
from io import BytesIO
from google.genai import types
from google import genai
from huggingface_hub import InferenceClient

def generate_text_to_video(text_description: str, audio_description_path: str = None, video_description_path: str = None):

    with open('../../apikey.txt', 'r') as f:
        api_key = f.read().strip()

    with open('../../hfapikey.txt', 'r') as f:
        hfi_apikey = f.read().strip()

    prompt_client = genai.Client(api_key=api_key)

    video_generation_prompt = """
    You are an AI agent in an AI-based and emotionally aware journaling application. The system works as follows:
    1. Obtain the data from the user.
    2. Process the text, audio, and video descriptions to create a suitable prompt for video generation.
    3. Use the GenAI API to generate a video based on the processed descriptions.
    4. The video should be visually engaging, emotionally resonant, and in an anime style.

    The user will provide a week's worth of data in a structured format, including text, images, audio, and video. Your task is to select the most meaningful and impactful moments that reflect the user's personality and significant events.

    You need to generate a high-quality and concise prompt to create a short, cinematic anime-style video summarizing the user's week. The video should be touching, inspiring, and visually captivating, showcasing the best moments from the user's journal.

    Prompt generation guidelines:
    1. The prompt should be concise and clear, under 100 words.
    2. Use plain text without special characters.
    3. The prompt should describe a cinematic and emotionally engaging anime-style video.
    4. The video should summarize the user's week with the most meaningful moments from their journal.
    """
    video_generation_prompt = [video_generation_prompt, text_description]

    if audio_description_path is not None:
      audio_description = prompt_client.files.upload(file="audio_description_path")
      video_generation_prompt = video_generation_prompt + [audio_description]

    if video_description_path is not None:
      video_description = prompt_client.files.upload(file="video_description_path")
      video_generation_prompt =  video_generation_prompt + [video_description]

    prompt_model = "gemini-2.5-pro"

    prompt_response = prompt_client.models.generate_content(
        model=prompt_model,
        contents= video_generation_prompt,
    )
    video_prompt = prompt_response.text
    print(f"Image Prompt: {video_prompt}")

    contents = video_generation_prompt
    video_client = InferenceClient(
        provider="auto",
        api_key=hfi_apikey,
    )
    video = video_client.text_to_video(
        prompt=video_prompt,
        model="Wan-AI/Wan2.2-T2V-A14B",
    )
    with open(f"videos/video.mp4", 'wb') as f:
        f.write(video)
    print(f"Video saved as video.mp4")



def generate_text_to_image(text_description: str, audio_description_path: str = None, video_description_path: str = None):
    """
        Basically what we are gonna do is take the suitable description and convert into suitable prompt for
        the comic style image generation model., we gotta take care of the length of the description too so
        that we don't fucking run out of the token limit for the model, this is why ill use the gemini 2.0 flash
        image preview model.

    """
    with open('../../apikey.txt', 'r') as f:
        api_key = f.read().strip()

    client = genai.Client(api_key=api_key)
    system_image_prompt = """ 
    
    You are an AI agent in a AI based and emotionally aware journaling application, the system basically works like this:
    1. Obtain the data from the user
    2. Process the text, audio, and video descriptions to create a suitable prompt for image generation
    3. Use the Google GenAI API to generate an image based on the processed descriptions
    4. The text should be clearly legible and readable 
    
    So basically I will be passing you the user data and all in a structured format and all. So let me explain it to you 
    in an even more elaborate way. So we take the users week's worth of data which can be text, images, audio and video.
    
    I will pass you the data in the correct order and format with the days and the dates, you have to select the best 
    things that are closer to the persons personality and which matter more to him or her.
    
    I need you to give out a very good and a clean prompt to give to an image generation model so that we can generate 
    a very clean comic strip of the persons week in a manga style, make sure the prompt is under 500 words and goes on 
    to neatly elaborate the persons week in a manner that is touching and inspiring, the prompt will be used and given 
    to an text to image model to generate a comic styles page of the persons week with the best momemts taken out of his 
    journal which will be passed to you.
    
    Prompt generation guidelines:
    1. The prompt should be concise and clear, under 500 words.
    2. No special characters or anything, just plain text.
    3. The prompt should be in a comic style, with a manga feel to it
    4. The prompt should be able to generate a comic strip of the persons week with the best moments taken out of his journal.
    
    """
    image_generation_prompt = [system_image_prompt, text_description]

    if audio_description_path is not None:
      audio_description = client.files.upload(file="audio_description_path")
      image_generation_prompt = image_generation_prompt + [audio_description]

    if video_description_path is not None:
      video_description = client.files.upload(file="video_description_path")
      image_generation_prompt =  image_generation_prompt + [video_description]

    prompt_model = "gemini-2.5-pro"

    prompt_response = client.models.generate_content(
                model=prompt_model,
                contents= image_generation_prompt,
            )
    image_prompt = prompt_response.text
    print(f"Image Prompt: {image_prompt}")

    contents = image_prompt
    
    try:
            response = client.models.generate_content(
                model="gemini-2.0-flash-preview-image-generation",
                contents=contents,
                config=types.GenerateContentConfig(
                    response_modalities=['TEXT', 'IMAGE']
                )
            )
            for part in response.candidates[0].content.parts:
                if part.text is not None:
                    print(part.text)
                elif part.inline_data is not None:
                    image = Image.open(BytesIO((part.inline_data.data)))
                    image.save(f"image4.png")
                    print(f"Image saved as image3.png")

    except FileNotFoundError:
        print("API key file not found. Please ensure 'apikey.txt' exists with your API key.")

journal = """
Date: August 9, 2025  
Location: Cyber Defense Operations Center  

Today was another intense day in the world of cybersecurity. The morning started with a briefing on the latest threat intelligence reports. A new ransomware variant, dubbed "ShadowCrypt," has been making waves in the wild, targeting critical infrastructure. Our team was tasked with analyzing its behavior and preparing countermeasures.  

I spent the first few hours reverse-engineering the malware in a sandbox environment. The code was obfuscated, as expected, but after some persistence, I uncovered its encryption routine and command-and-control (C2) communication patterns. It’s always fascinating to see the level of sophistication attackers employ, but it’s also a reminder of the stakes involved.  

Midday, we had a simulated phishing attack drill for one of our clients. The results were mixed—some employees fell for the bait, but others reported the suspicious emails promptly. It’s a continuous battle to raise awareness and improve security hygiene across organizations.  

After lunch, I worked on patching a vulnerability in one of our internal systems. It was a race against time, as exploit code for the vulnerability had just been published online. Thankfully, we were able to deploy the fix before any signs of compromise.  

The highlight of the day was a live incident response. A financial institution reported unusual activity on their network, and we were called in to assist. It turned out to be a sophisticated spear-phishing attack that compromised a high-level executive’s account. We quickly isolated the affected systems, traced the attacker’s movements, and mitigated the breach.  

As the day wound down, I reviewed our team’s progress and documented lessons learned from the incident. Continuous improvement is key in this field, as the threat landscape evolves rapidly.  

Before heading home, I took a moment to reflect on the importance of our work. Cybersecurity is a relentless field, but knowing that we’re protecting people and organizations from harm makes it all worthwhile.  

Goodnight from the frontlines of cyberspace.
"""

generate_text_to_video(journal)