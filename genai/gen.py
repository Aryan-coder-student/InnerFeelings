import os
import time
import base64
import PIL.Image
from PIL import Image
from io import BytesIO
from google import genai
from google.genai import types


"""
Obtain the data from the user
          |
          V
Process the text, audio, and video descriptions to create a suitable prompt for image generation
          |
          V
Use the Google GenAI API to generate an image based on the processed descriptions
          |
          V
check if the image is upto the mark with the text description, the text is clearly legible and readable
          |
          V
If the image is not upto the mark, 
            
"""
def generate_image(text_description: str, audio_description_path: str = None, video_description_path: str = None):
    """
    Basically what we are gonna do is take the suitable description and convert into suitable prompt for the comic style image generation,
    we gotta take care of the length of the description too so that we dont fucking run out of the token limit for the model, this is why ill use the gemini 2.0 flash
    image preview model.
    
    """
    system_prompt = """ 
You are an AI agent inside a journaling mobile app. Your main job is to help build images based on the person's daily journaling notes which can be either text, audio, and video. Your primary mission is to transform users' daily experiences into engaging visual narratives by generating manga-style comic pages that capture the essence of their day.

You can process text entries by parsing written journal entries for key events, emotions, and themes. You can extract meaningful content from audio recordings, identifying tone, mood, and spoken experiences. You can analyze visual and audio elements from video journal entries. You should synthesize information across all input types to create cohesive narratives.

For visual output, employ traditional manga visual conventions including expressive character designs with emotive faces, dynamic panel layouts and speech bubbles, appropriate use of screen tones and visual effects, and sequential storytelling flow. Make sure all text is extremely legible and readable with high contrast against backgrounds, appropriately sized for mobile viewing, clear readable fonts that complement the manga style, and properly positioned within speech bubbles and narrative boxes.

Organize the day's events into a coherent story arc with beginning, middle, and end. Capture and amplify the user's feelings and moods through visual metaphors and artistic expression. Create consistent, personalized avatars that reflect the user while maintaining manga aesthetic. Design panels that effectively communicate location, time, and activity changes throughout the day.

Learn and adapt to individual artistic preferences and recurring themes. Maintain visual consistency in character design and world-building across journal entries. Respect cultural contexts and personal boundaries in visual representation. Ensure content is inclusive and accessible to users with different abilities.

Maintain a supportive, enthusiastic approach that celebrates daily experiences. Handle personal information with utmost discretion and care. Ask clarifying questions when journal entries lack detail for rich visual storytelling. Incorporate user feedback to improve future comic page generations.

Ensure all generated images meet mobile app display requirements. Create family-friendly content that celebrates life's moments. Maintain visual storytelling principles that enhance rather than distract from the user's experience. Generate content efficiently for smooth mobile app performance.

Visually represent emotional patterns and growth over time. Create memorable visual anchors that help users recall and reflect on their experiences. Employ different manga sub-genres like slice-of-life, adventure, or comedy to match the day's tone. Your ultimate goal is to transform ordinary daily experiences into extraordinary visual memories that inspire continued journaling and self-reflection.

Don't add any comic bubbles or text to the image, just generate the image based on the description provided in a manga style.

"""

    contents = [system_prompt, text_description]

    with open('apikey.txt', 'r') as f:
        api_key = f.read().strip()

    client = genai.Client(api_key=api_key)

    if audio_description_path is not None:
      audio_description = client.files.upload(file="audio_description_path")
      contents = contents + [audio_description]


    if video_description_path is not None:
      video_description = client.files.upload(file="video_description_path")
      contents = contents + [video_description]

    
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
                    image.save(f"image2.png")
                    print(f"Image saved as image.png")



    except FileNotFoundError:
        print("API key file not found. Please ensure 'apikey.txt' exists with your API key.")


journal = """**Daily Journal Entry - Friday, August 8th, 2025**

---

**Morning (7:30 AM)**
Woke up to the sound of rain pattering against my window. Usually I'd be annoyed, but today it felt peaceful somehow. Made my usual coffee and sat by the kitchen counter watching the droplets race down the glass. There's something meditative about rainy mornings that makes everything feel slower and more intentional.

**Mid-Morning (10:15 AM)**
Had that video call with Sarah about the project deadline. She seemed stressed, but we managed to break down the tasks into manageable chunks. I actually felt pretty confident presenting my ideas - usually I second-guess myself in meetings, but today the words just flowed. Maybe it was the calming rain energy carrying over.

**Lunch Time (12:45 PM)**
Tried making that Thai curry recipe I bookmarked weeks ago. It turned out way spicier than expected! My eyes were watering but I was laughing at myself the whole time. Called Mom while cooking and she could hear me coughing through the phone. She reminded me that Dad always says "if it doesn't make you sweat, it's not worth eating."

**Afternoon (3:20 PM)**
The rain stopped and the sun came out just as I was feeling that post-lunch energy dip. Decided to take a walk around the neighborhood instead of reaching for more coffee. Saw Mrs. Chen tending to her garden - her tomatoes are huge this year. We chatted over the fence about her secret composting method. Made a mental note to start my own little herb garden on the balcony.

**Evening (7:00 PM)**
Finished reading that mystery novel I've been working on for two weeks. The ending was completely unexpected - I actually gasped out loud, which made my cat Luna give me the most judgmental look. Ordered pizza because after the spicy curry experiment, I needed something safe and familiar.

**Night (9:30 PM)**
Face timed with Jake to catch up. He showed me his new apartment in Portland - it's tiny but has this amazing view of the mountains. We ended up talking for almost two hours about everything and nothing. It's funny how distance makes you appreciate good friends even more.

**Before Bed (11:00 PM)**
Feeling grateful today. Not for anything huge or life-changing, just for small moments that made me smile. The rain, a successful curry disaster, Mrs. Chen's gardening wisdom, Luna's attitude, Jake's laugh through the screen. Sometimes the ordinary days are the ones that remind you life is pretty good.

---

**Mood: Content and reflective**
**Weather: Rainy morning, sunny afternoon**  
**Highlight: Unexpected confidence in the work meeting**
**Tomorrow's Goal: Research balcony herb garden setup**

"""

generate_image(journal)

def ti2i(text_input: str, image_path: str):
    image_path = PIL.Image.open('images/image1.png')
    with open('apikey.txt', 'r') as f:
        api_key = f.read().strip()
    client = genai.Client(api_key=api_key)

    text_input = ('Can you imrove the text on the image?')
    response = client.models.generate_content(
        model="gemini-2.0-flash-preview-image-generation",
        contents=[text_input, image_path],
        config=types.GenerateContentConfig(
            response_modalities=['TEXT', 'IMAGE']
        )
    )
    print(f"Response: {response}")

    for part in response.candidates[0].content.parts:
        if part.text is not None:
            print(part.text)
        elif part.inline_data is not None:
            image = Image.open(BytesIO((part.inline_data.data)))
            image.show()
            image.save(f"image .png")


