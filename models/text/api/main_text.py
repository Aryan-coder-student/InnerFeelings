import os
import warnings
import torch
from fastapi import APIRouter
from pydantic import BaseModel
from transformers import AutoModelForSequenceClassification, AutoTokenizer
from transformers import logging

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

logging.set_verbosity_error()
warnings.filterwarnings("ignore")

class SentimentAnalyzer:
    ID2LABEL = {
        "0": "sadness",
        "1": "joy",
        "2": "love",
        "3": "anger",
        "4": "fear",
        "5": "surprise",
    }

    def __init__(self, tokenizer_name_or_path: str = "xlm-roberta-base"):
        
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model = AutoModelForSequenceClassification.from_pretrained("../text_save_model/xlm_robert_model_3").to(self.device)
        self.tokenizer = AutoTokenizer.from_pretrained(tokenizer_name_or_path, cache_dir="../tokenizer_cache")
        self.router = APIRouter(prefix="/text")
        self._add_routes()

    def _add_routes(self):
        @self.router.post("/predict")
        async def predict_endpoint(req: PredictRequest):
            scores = self.predict(req.text)
            top_label = max(scores, key=scores.get)
            return {
                "scores": scores,
                "top_label": top_label,
                "top_score": scores[top_label],
            }

    def predict(self, text: str):
        chunks = []
        idx = 0
        while idx < len(text):
            chunks.append(text[idx: idx + 512])
            idx += 512
        if not chunks:
            chunks = [text]

        logits_list = []
        for sen in chunks:
            inputs = self.tokenizer(
                sen,
                return_tensors="pt",
                truncation=True,
                padding=True,
                max_length=512,
            )
            inputs = {k: v.to(self.device) for k, v in inputs.items()}
            with torch.no_grad():
                outputs = self.model(**inputs)
                logits = outputs.logits.squeeze(0)
                logits_list.append(logits)

        avg_logits = torch.stack(logits_list, dim=0).mean(dim=0)

        label_scores = {}
        for i, logit in enumerate(avg_logits.tolist()):
            label = self.ID2LABEL.get(str(i), str(i))
            label_scores[label] = logit

        return label_scores


class PredictRequest(BaseModel):
    text: str

if __name__ == "__main__":
    analyzer = SentimentAnalyzer()


    # If you set up a FastAPI app, include the router:
    # from fastapi import FastAPI
    # app = FastAPI()
    # app.include_router(analyzer.router)
