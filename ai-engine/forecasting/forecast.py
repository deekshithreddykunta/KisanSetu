import numpy as np


class ForecastEngine:

    def moving_average(self, values, window=3):

        if not values:
            return []

        values = np.array(values)

        result = []

        for i in range(len(values)):

            start = max(0, i - window + 1)

            result.append(
                float(np.mean(values[start:i + 1]))
            )

        return result

    def next_value(self, values, window=3):

        if not values:
            return 0

        recent = values[-window:]

        return round(
            float(np.mean(recent)),
            2
        )