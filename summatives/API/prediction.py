from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import os


# FastAPI app setup
app = FastAPI(title="Airline Price Prediction API")

# CORS middleware
origins = ["*"]  
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Load ML model
MODEL_PATH = "best_model.pkl"

if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(
        f"Model file '{MODEL_PATH}' not found. Make sure it's in the same folder as this script.")

model = joblib.load(MODEL_PATH)


# Pydantic model for request
class FlightInput(BaseModel):
    stops: int = Field(..., ge=0, le=3)
    duration: float = Field(..., gt=0)
    days_left: int = Field(..., ge=0)

    airline_Air_India: int
    airline_GO_FIRST: int
    airline_Indigo: int
    airline_SpiceJet: int
    airline_Vistara: int

    class_Economy: int

    departure_time_Early_Morning: int
    departure_time_Morning: int
    departure_time_Evening: int
    departure_time_Late_Night: int
    departure_time_Night: int


# Prediction endpoint
@app.post("/predict")
def predict_price(flight: FlightInput):
    try:
        # Convert input into the correct model format
        input_data = np.array([
            flight.stops,
            flight.duration,
            flight.days_left,
            flight.airline_Air_India,
            flight.airline_GO_FIRST,
            flight.airline_Indigo,
            flight.airline_SpiceJet,
            flight.airline_Vistara,
            flight.class_Economy,
            flight.departure_time_Early_Morning,
            flight.departure_time_Morning,
            flight.departure_time_Evening,
            flight.departure_time_Late_Night,
            flight.departure_time_Night
        ]).reshape(1, -1)

        # Make prediction
        predicted_price = model.predict(input_data)[0]

        # Return result
        return {"predicted_price": round(float(predicted_price), 2)}

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {e}")
