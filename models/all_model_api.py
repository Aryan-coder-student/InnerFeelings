from fastapi import FastAPI
from text.api.main_text import SentimentAnalyzer
analyzer = SentimentAnalyzer()
app = FastAPI()
app.include_router(analyzer.router)
