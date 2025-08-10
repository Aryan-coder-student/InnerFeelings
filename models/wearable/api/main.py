from langchain_groq import ChatGroq 
from langchain_core.prompts import PromptTemplate
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from langchain_community.utilities import SerpAPIWrapper
from fastapi import APIRouter
from pydantic import BaseModel ,Field
from typing import List 
load_dotenv()
import os 
api_key = os.getenv("GROQ_API_KEY")
os.environ["SERPAPI_API_KEY"] = os.getenv("SERPAPI_API_KEY")

wearable_router = APIRouter(prefix="/wearable",tags=["wearble"])

model = ChatGroq(
    api_key=str(api_key),
    model="openai/gpt-oss-20b"
)


class WearableData(BaseModel):
    oxygen :int
    sleep_duration :str 
    heart_rate:int 
    steps :int 
    activity : List[str]
    gender : str 
    age : int 

class AnalysisOutput(BaseModel):
    oxygen: float
    sleep_duration: float
    heart_rate: float
    steps: int
    activity: List[str]
    sentiment: List[str]
    insight: str = Field(..., description="Concise health insight based on data & research")


query_prompt_template = PromptTemplate.from_template("""
You are a fitness analyst.  
Given wearable data:  
oxygen: {oxygen}  
sleep_duration: {sleep_duration}  
heart_rate: {heart_rate}  
steps: {steps}  
activity: {activity}  
gender: {gender}  
age: {age}  

Generate ONE concise Google search query  
that would help find useful, science-based insights or advice for the current health state.  
Only output the query text.
""")


@wearable_router.post("/predict")
def predict_wearable(data: WearableData):
    wearable_data = data.dict()

    query_prompt = query_prompt_template.format(**wearable_data)
    search_query = model.invoke(query_prompt).content


    search_tool = SerpAPIWrapper()
    search_results = search_tool.run(search_query)

    
    structured_model = model.with_structured_output(AnalysisOutput)

    analysis_prompt = PromptTemplate.from_template("""
    You are a fitness analyser.
    You have wearable readings:
    oxygen: {oxygen}
    sleep_duration: {sleep_duration}
    heart_rate: {heart_rate}
    steps: {steps}
    activity: {activity}
    gender: {gender}
    age: {age}

    Also, here are Google search results for relevant health advice:
    {search_results}

    Using BOTH the wearable readings and search results, return a JSON object that matches this schema exactly:
    {{
    "oxygen": float,
    "sleep_duration": float,
    "heart_rate": float,
    "steps": int,
    "activity": ["string", "string"],
    "sentiment": ["string"],
    "insight": "string"
    }}

    Rules:
    - activity must be a JSON array, e.g., ["walking", "yoga"]
    - sentiment must be a JSON array, e.g., ["neutral"] or ["positive", "motivated"]
    - insight must be a plain string
    """).format(**wearable_data, search_results=search_results)

    final_analysis: AnalysisOutput = structured_model.invoke(analysis_prompt)
    return JSONResponse(content=final_analysis.dict())