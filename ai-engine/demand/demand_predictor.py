import numpy as np


class DemandPredictor:

    def predict(self, historical_demand):

        if not historical_demand:
            return 0

        data = np.array(historical_demand)

        if len(data) == 1:
            return round(float(data[0]), 2)

        recent = data[-5:]

        weights = np.arange(1, len(recent) + 1)

        prediction = np.average(
            recent,
            weights=weights
        )

        return round(float(prediction), 2)