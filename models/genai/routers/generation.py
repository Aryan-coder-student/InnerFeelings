import os
from pathlib import Path
from typing import Optional

from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from fastapi.responses import FileResponse, JSONResponse

from google import genai
from google.genai import types
from huggingface_hub import InferenceClient
from PIL import Image
from io import BytesIO

gen_router = APIRouter(prefix="/genai_tool", tags=["Generative AI"])

# Ensure artifact directories
ARTIFACTS_DIR = Path("artifacts")
VIDEO_DIR = ARTIFACTS_DIR / "videos"
IMAGE_DIR = ARTIFACTS_DIR / "images"
VIDEO_DIR.mkdir(parents=True, exist_ok=True)
IMAGE_DIR.mkdir(parents=True, exist_ok=True)

def _load_key(env_name: str, fallback_path: Optional[Path]) -> Optional[str]:
    key = os.getenv(env_name)
    if key:
        return key.strip()
    if fallback_path and fallback_path.exists():
        return fallback_path.read_text().strip()
    return None

def _get_google_client() -> genai.Client:
    api_key = _load_key("GOOGLE_API_KEY", Path("../../apikey.txt"))
    if not api_key:
        raise HTTPException(status_code=500, detail="Missing GOOGLE_API_KEY or ../apikey.txt")
    return genai.Client(api_key=api_key)

def _get_hf_client() -> InferenceClient:
    hf_key = _load_key("HF_API_KEY", Path("../../hfapikey.txt"))
    if not hf_key:
        raise HTTPException(status_code=500, detail="Missing HF_API_KEY or ../hfapikey.txt")
    return InferenceClient(provider="auto", api_key=hf_key)

@gen_router.post("/text-to-video")
async def text_to_video(
    text_description: str = Form(...),
    # audio_description: Optional[UploadFile] = File(None),
    # video_description: Optional[UploadFile] = File(None),
):
    print("Called")
    """
    Generates a short video from a weekly journal description.
    - text_description: the weekly journal text
    - audio_description: optional audio file describing week
    - video_description: optional video file describing week
    Returns: JSON with output path and the generated prompt.
    """
    try:
        prompt_client = _get_google_client()

        system_prompt = """
        You are an AI agent in an AI-based and emotionally aware journaling application. The system works as follows:
        1. Obtain the data from the user.
        2. Process the text, audio, and video descriptions to create a suitable prompt for video generation.
        3. Use the GenAI API to generate a video based on the processed descriptions.
        4. The video should be visually engaging, emotionally resonant, and in an anime style.

        The user will provide a week's worth of data in a structured format, including text, images, audio, and video. Your task is to select the most meaningful and impactful moments that reflect the user's personality and significant events.

        You need to generate a high-quality and concise prompt to create a short, cinematic anime-style video summarizing the user's week. The video should be touching, inspiring, and visually captivating, showcasing the best moments from the user's journal.

        Prompt guidelines:
        1. Under 100 words.
        2. Plain text only.
        3. Cinematic, emotionally engaging anime-style.
        4. Summarize the week with meaningful moments.
        """

        contents: list = [system_prompt, text_description]

        # # Upload optional files properly
        # if audio_description is not None:
        #     audio_bytes = await audio_description.read()
        #     audio_uploaded = prompt_client.files.upload_bytes(
        #         data=audio_bytes,
        #         display_name=audio_description.filename or "audio_description"
        #     )
        #     contents.append(audio_uploaded)

        # if video_description is not None:
        #     video_bytes = await video_description.read()
        #     video_uploaded = prompt_client.files.upload_bytes(
        #         data=video_bytes,
        #         display_name=video_description.filename or "video_description"
        #     )
        #     contents.append(video_uploaded)

        # Generate the video prompt
        prompt_model = "gemini-2.5-pro"
        prompt_response = prompt_client.models.generate_content(
            model=prompt_model,
            contents=contents,
        )
        video_prompt = getattr(prompt_response, "text", None)
        if not video_prompt:
            raise HTTPException(status_code=500, detail="Failed to get text from prompt response")

        # Generate video via HF
        hf_client = _get_hf_client()
        # Model from your code
        model_id = "Wan-AI/Wan2.2-T2V-A14B"

        video_bytes = hf_client.text_to_video(
            prompt=video_prompt,
            model=model_id,
        )
        output_path = VIDEO_DIR / "video.mp4"
        with open(output_path, "wb") as f:
            f.write(video_bytes)

        return JSONResponse({
            "status": "success",
            "video_path": str(output_path),
            "prompt": video_prompt,
            "model": model_id
        })

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@gen_router.post("/text-to-image")
async def text_to_image(
    text_description: str = Form(...),
    # audio_description: Optional[UploadFile] = File(None),
    # video_description: Optional[UploadFile] = File(None),
):
    """
    Generates a manga-style comic image from a weekly journal description.
    Returns: JSON with output path and the generated prompt.
    """
    try:
        client = _get_google_client()

        system_image_prompt = """
        You are an AI agent in an emotionally aware journaling app:
        1. Obtain the user's weekly data.
        2. Process text, audio, and video descriptions to create a suitable prompt for image generation.
        3. Use Google GenAI to generate an image; text must be legible.
        4. Output a manga-style comic strip summary of the week.

        Requirements:
        - Under 500 words.
        - Plain text only.
        - Comic, manga feel.
        - Summarize the week with best moments.
        """

        contents: list = [system_image_prompt, text_description]

        # if audio_description is not None:
        #     audio_bytes = await audio_description.read()
        #     audio_uploaded = client.files.upload_bytes(
        #         data=audio_bytes,
        #         display_name=audio_description.filename or "audio_description"
        #     )
        #     contents.append(audio_uploaded)

        # if video_description is not None:
        #     video_bytes = await video_description.read()
        #     video_uploaded = client.files.upload_bytes(
        #         data=video_bytes,
        #         display_name=video_description.filename or "video_description"
        #     )
        #     contents.append(video_uploaded)

        prompt_model = "gemini-2.5-pro"
        prompt_response = client.models.generate_content(
            model=prompt_model,
            contents=contents,
        )
        image_prompt = getattr(prompt_response, "text", None)
        if not image_prompt:
            raise HTTPException(status_code=500, detail="Failed to get text from prompt response")

        # Generate image using Gemini Image Generation
        response = client.models.generate_content(
            model="gemini-2.0-flash-preview-image-generation",
            contents=image_prompt,
            config=types.GenerateContentConfig(response_modalities=["TEXT", "IMAGE"])
        )

        image_saved = False
        saved_path = IMAGE_DIR / "image.png"
        # Iterate returned parts; save first image
        for part in response.candidates[0].content.parts:
            if getattr(part, "inline_data", None) and getattr(part.inline_data, "data", None):
                img = Image.open(BytesIO(part.inline_data.data))
                img.save(saved_path)
                image_saved = True
                break

        if not image_saved:
            raise HTTPException(status_code=500, detail="No image data returned from model")

        return JSONResponse({
            "status": "success",
            "image_path": str(saved_path),
            "prompt": image_prompt,
            "model": "gemini-2.0-flash-preview-image-generation"
        })

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

