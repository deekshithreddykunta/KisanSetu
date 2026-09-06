from pricing.price_predictor import PricePredictor
from demand.demand_predictor import DemandPredictor
from supply_risk.risk_predictor import SupplyRiskPredictor


class RecommendationAgent:

    def __init__(self):

        self.price_predictor = PricePredictor()
        self.demand_predictor = DemandPredictor()
        self.risk_predictor = SupplyRiskPredictor()

    def recommend(
        self,
        current_price,
        historical_demand,
        temperature,
        rainfall,
        supply
    ):

        demand = self.demand_predictor.predict(
            historical_demand
        )

        price = self.price_predictor.predict(
            current_price,
            demand,
            supply
        )

        risk = self.risk_predictor.predict(
            temperature,
            rainfall,
            demand,
            supply
        )

        return {
            "predicted_demand": demand,
            "recommended_price": price,
            "supply_risk": risk
        }