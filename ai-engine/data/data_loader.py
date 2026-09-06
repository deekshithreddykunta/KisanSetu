from sqlalchemy import text


def get_crop_history(db, crop_name, limit=100):

    query = text("""
        SELECT *
        FROM crop_prices
        WHERE crop_name = :crop_name
        ORDER BY date DESC
        LIMIT :limit
    """)

    result = db.execute(
        query,
        {
            "crop_name": crop_name,
            "limit": limit
        }
    )

    return [dict(row._mapping) for row in result]