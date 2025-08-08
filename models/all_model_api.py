from fastapi import FastAPI
from text.api.main_text import SentimentAnalyzer
from voice.api import main 
analyzer = SentimentAnalyzer()
app = FastAPI()
app.include_router(analyzer.router)
app.include_router(main.voice_router)

