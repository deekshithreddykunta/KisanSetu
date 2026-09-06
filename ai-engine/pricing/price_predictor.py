import numpy as np


class PricePredictor:

    def predict(self, current_price: float, demand: float = 1.0,
                supply: float = 1.0):

        if supply <= 0:
            supply = 1

        demand_supply_ratio = demand / supply

        adjustment = 1 + (0.10 * (demand_supply_ratio - 1))

        predicted_price = current_price * adjustment

        return round(predicted_price, 2)


def get_fair_price(current_price, demand=1.0, supply=1.0):

    predictor = PricePredictor()

    return predictor.predict(
        current_price,
        demand,
        supply
    )