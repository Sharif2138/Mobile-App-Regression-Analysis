# Airline Price Predictor

## Mission and Problem
**Problem:** Airline ticket prices fluctuate significantly based on stops, travel duration, and booking time etc making it difficult for travelers to predict costs hence poor budgeting and palnnimg for their flights.  

**Mission:** Build a machine learning model to predict airline ticket prices using regression analysis, and deploy it via a FastAPI endpoint for use in a Flutter mobile app to help travellers and travel agencies predict fight prices sccurately for better planing 

## API Endpoint
- **URL:** [https://mobile-app-regression-analysis.onrender.com](https://mobile-app-regression-analysis.onrender.com)  
- **Swagger UI:** [https://mobile-app-regression-analysis.onrender.com/docs](https://mobile-app-regression-analysis.onrender.com/docs)  
- Accepts JSON POST requests with input variables (`stops`, `duration`, `days_left`, `airline`, `departure_time`) and returns predicted ticket price.

## Video Demo
- **YouTube Link:** [https://youtu.be/8bZJg_fW3YQ](https://youtu.be/8bZJg_fW3YQ)  
- Max 5 minutes demonstrating Flutter app, API, Swagger UI, and prediction workflow.

## How to Run Mobile App
1. Clone the repo:
git clone git@github.com:Sharif2138/Mobile-App-Regression-Analysis.git
cd summatives/flutter_mobile_app

Run flutter pub get
Then flutter run
