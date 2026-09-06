from fastapi import FastAPI

from models.schemas import (
    PriceRequest,
    DemandRequest,
    LogisticsRequest,
    MatchingRequest,
    RiskRequest,
    ShelfLifeRequest,
    WasteRequest,
    QualityRequest,
    FraudRequest,
    FertilizerRequest,
)

from pricing.price_predictor import PricePredictor
from demand.demand_predictor import DemandPredictor
from logistics.route_optimizer import LogisticsOptimizer
from matching.farmer_buyer_matcher import FarmerBuyerMatcher
from supply_risk.risk_predictor import SupplyRiskPredictor
from shelf_life.shelf_life_predictor import ShelfLifePredictor
from waste.waste_predictor import WastePredictor
from quality.quality_analyzer import QualityAnalyzer
from fraud.fraud_detector import FraudDetector
from fertilizer.fertilizer_recommender import FertilizerRecommender



app = FastAPI(
    title="KisanSetu AI Engine",
    description="AI Engine for KisanSetu Agriculture Platform",
    version="1.0.0",
)




price_predictor = PricePredictor()
demand_predictor = DemandPredictor()
logistics_optimizer = LogisticsOptimizer()
farmer_buyer_matcher = FarmerBuyerMatcher()
supply_risk_predictor = SupplyRiskPredictor()
shelf_life_predictor = ShelfLifePredictor()
waste_predictor = WastePredictor()
quality_analyzer = QualityAnalyzer()
fraud_detector = FraudDetector()
fertilizer_recommender = FertilizerRecommender()



@app.get("/")
def home():

    return {
        "message": "KisanSetu AI Engine is running",
        "status": "success",
        "version": "1.0.0",
    }




@app.get("/health")
def health():

    return {
        "status": "healthy"
    }




@app.post("/ai/price")
def predict_price(request: PriceRequest):

    price = price_predictor.predict(
        request.current_price
    )

    return {
        "crop": request.crop_name,
        "current_price": request.current_price,
        "recommended_price": price,
    }



@app.post("/ai/demand")
def predict_demand(request: DemandRequest):

    prediction = demand_predictor.predict(
        request.historical_demand
    )

    return {
        "crop": request.crop_name,
        "predicted_demand": prediction,
    }




@app.post("/ai/logistics")
def optimize_logistics(
    request: LogisticsRequest
):

    return logistics_optimizer.optimize(
        request.distance_km,
        request.quantity,
    )




@app.post("/ai/matching")
def match_buyers(
    request: MatchingRequest
):

    return farmer_buyer_matcher.match(
        request.crop_name,
        request.quantity,
        request.buyer_locations,
        request.farmer_location,
    )



@app.post("/ai/risk")
def predict_risk(request: RiskRequest):

    return supply_risk_predictor.predict(
        request.temperature,
        request.rainfall,
        request.demand,
        request.supply,
    )




@app.post("/ai/shelf-life")
def predict_shelf_life(
    request: ShelfLifeRequest
):

    return shelf_life_predictor.predict(
        request.crop_name,
        request.temperature,
        request.humidity,
    )




@app.post("/ai/waste")
def predict_waste(
    request: WasteRequest
):

    return waste_predictor.predict(
        request.crop_name,
        request.quantity,
        request.shelf_life_days,
    )




@app.post("/ai/quality")
def analyze_quality(
    request: QualityRequest
):

    return quality_analyzer.analyze(
        request.crop_name,
        request.moisture,
        request.temperature,
    )




@app.post("/ai/fraud")
def detect_fraud(
    request: FraudRequest
):

    return fraud_detector.detect(
        request.transaction_amount,
        request.transaction_count,
    )




@app.post("/ai/fertilizer")
def recommend_fertilizer(
    request: FertilizerRequest
):

    return fertilizer_recommender.recommend(
        request.nitrogen,
        request.phosphorus,
        request.potassium,
        request.ph,
    )
