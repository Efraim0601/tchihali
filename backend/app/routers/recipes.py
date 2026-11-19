from fastapi import APIRouter, Depends, HTTPException

from ..db import get_conn

router = APIRouter(prefix="/recipes", tags=["recipes"])

_SQL = """
select r.*, coalesce(json_agg(json_build_object(
         'name', json_build_object('fr', i.name_fr, 'en', i.name_en),
         'qty',  json_build_object('fr', i.qty_fr,  'en', i.qty_en)) order by i.position)
         filter (where i.recipe_id is not null), '[]') as ingredients
from recipes r left join recipe_ingredients i on i.recipe_id = r.id
{where}
group by r.id order by r.name_fr
"""


def _recipe(r: dict) -> dict:
    return {
        "id": r["id"],
        "name": {"fr": r["name_fr"], "en": r["name_en"]},
        "detail_title": {"fr": r["detail_title_fr"], "en": r["detail_title_en"]} if r["detail_title_fr"] else None,
        "kcal": r["kcal"],
        "detail_kcal": r["detail_kcal"],
        "time": r["time"],
        "tags": r["tags"],
        "c1": r["c1"], "c2": r["c2"], "c3": r["c3"], "tint": r["tint"],
        "servings": r["servings"],
        "difficulty": r["difficulty"],
        "protein": r["protein"], "carbs": r["carbs"], "fat": r["fat"],
        "ingredients": r["ingredients"],
    }


@router.get("")
def list_recipes(conn=Depends(get_conn)):
    return [_recipe(r) for r in conn.execute(_SQL.format(where="")).fetchall()]


@router.get("/{recipe_id}")
def get_recipe(recipe_id: str, conn=Depends(get_conn)):
    row = conn.execute(_SQL.format(where="where r.id = %s"), (recipe_id,)).fetchone()
    if row is None:
        raise HTTPException(404, "Recette introuvable")
    return _recipe(row)
