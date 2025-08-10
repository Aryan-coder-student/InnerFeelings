from fastapi import FastAPI
from text.api.main_text import SentimentAnalyzer
from voice.api import main 
from genai.routers.generation import gen_router 
from wearable.api.main import wearable_router 
analyzer = SentimentAnalyzer()
app = FastAPI()
app.include_router(analyzer.router)
app.include_router(main.voice_router)
app.include_router(wearable_router)
app.include_router(gen_router)

