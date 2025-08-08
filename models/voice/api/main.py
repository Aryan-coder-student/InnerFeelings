from fastapi import FastAPI, APIRouter, UploadFile, File, HTTPException
import librosa
import io
import torch
from transformers import Wav2Vec2ForSequenceClassification, Wav2Vec2FeatureExtractor
import os

voice_router = APIRouter(prefix="/voice",
                         tags = ["voice"])

path_model = os.path.join("..", "Voice_model/")
model_name = "prithivMLmods/Speech-Emotion-Classification"
model = Wav2Vec2ForSequenceClassification.from_pretrained(model_name, cache_dir=path_model)
processor = Wav2Vec2FeatureExtractor.from_pretrained(model_name, cache_dir=path_model)

id2label = {
    "0": "Anger",
    "1": "Calm",
    "2": "Disgust",
    "3": "Fear",
    "4": "Happy",
    "5": "Neutral",
    "6": "Sad",
    "7": "Surprised"
}

@voice_router.post("/post")
async def classify_audio(file: UploadFile = File(...)):
    if not file.content_type.startswith("audio"):
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload an audio file.")
    contents = await file.read()

    
    audio_stream = io.BytesIO(contents)

    speech, sample_rate = librosa.load(audio_stream, sr=16000)


    inputs = processor(
        speech,
        sampling_rate=sample_rate,
        return_tensors="pt",
        padding=True
    )

    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        probs = torch.nn.functional.softmax(logits, dim=1).squeeze().tolist()
    prediction = {id2label[str(i)]: round(probs[i], 3) for i in range(len(probs))}

    return prediction


