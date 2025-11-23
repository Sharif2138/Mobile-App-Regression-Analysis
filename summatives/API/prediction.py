from fastapi import FastAPI
from pydantic import BaseModel, Field
import joblib
import numpy as np

model = joblib.load("best_model.pkl")
app = FastAPI(title="Airline Price Prediction API")

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


# 4. Create the prediction endpoint
@app.post("/predict")
def predict_price(flight: FlightInput):

    # Convert input into correct model format
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
        flight.departure_time_Evening,
        flight.departure_time_Late_Night,
        flight.departure_time_Morning,
        flight.departure_time_Night
    ]).reshape(1, -1)

    # Make prediction
    predicted_price = model.predict(input_data)[0]

    # Return result as JSON
    return {"predicted_price": round(float(predicted_price), 2)}
