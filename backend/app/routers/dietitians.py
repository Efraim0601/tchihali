from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

from fastapi import APIRouter, Depends, HTTPException, Query

from ..db import get_conn
from ..deps import current_user

router = APIRouter(prefix="/dietitians", tags=["dietitians"])
TZ = ZoneInfo("Africa/Douala")
LEAD_HOURS = 2  # on ne réserve pas un créneau qui commence dans moins de 2 h

# Prochain créneau libre : jours ouvrés avec disponibilité, hors jours fériés et créneaux déjà pris.
_DIRECTORY_SQL = """
select d.*, ns.starts_at as next_slot
from dietitians d
left join lateral (
  select ((gs.d::date + a.start_time) at time zone 'Africa/Douala') as starts_at
  from generate_series((now() at time zone 'Africa/Douala')::date,
                       (now() at time zone 'Africa/Douala')::date + 45, interval '1 day') as gs(d)
  join availability a on a.dietitian_id = d.id and a.weekday = extract(isodow from gs.d)::int
  where ((gs.d::date + a.start_time) at time zone 'Africa/Douala') > now() + make_interval(hours => %s)
    and not exists (select 1 from holidays h
                    where h.month = extract(month from gs.d)::int and h.day = extract(day from gs.d)::int)
    and not exists (select 1 from appointments ap
                    where ap.dietitian_id = d.id
                      and ap.starts_at = ((gs.d::date + a.start_time) at time zone 'Africa/Douala')
                      and ap.status in ('pending', 'confirmed'))
  order by 1 limit 1
) ns on true
order by d.name
"""


def _dietitian(row: dict) -> dict:
    return {
        "id": row["id"],
        "initials": row["initials"],
        "name": row["name"],
        "specialties": {"fr": row["specialties_fr"], "en": row["specialties_en"]},
        "languages": {"fr": row["languages_fr"], "en": row["languages_en"]},
        "video": row["video"],
        "in_person": row["in_person"],
        "avatar_bg": row["avatar_bg"],
        "avatar_fg": row["avatar_fg"],
        "next_slot": row["next_slot"].isoformat() if row["next_slot"] else None,
    }


@router.get("")
def list_dietitians(_=Depends(current_user), conn=Depends(get_conn)):
    return [_dietitian(r) for r in conn.execute(_DIRECTORY_SQL, (LEAD_HOURS,)).fetchall()]


def day_slots(conn, dietitian_id: str, day: date) -> list[dict]:
    """Créneaux d'un jour : [{time: '09:00', taken: bool}], vide si week-end / férié / passé."""
    if not conn.execute("select 1 from dietitians where id = %s", (dietitian_id,)).fetchone():
        raise HTTPException(404, "Diététicien introuvable")
    holiday = conn.execute(
        "select 1 from holidays where month = %s and day = %s", (day.month, day.day)
    ).fetchone()
    if holiday:
        return []
    rows = conn.execute(
        """select to_char(a.start_time, 'HH24:MI') as time,
                  ((%s::date + a.start_time) at time zone 'Africa/Douala') as starts_at,
                  exists (select 1 from appointments ap
                          where ap.dietitian_id = a.dietitian_id
                            and ap.starts_at = ((%s::date + a.start_time) at time zone 'Africa/Douala')
                            and ap.status in ('pending', 'confirmed')) as taken
           from availability a
           where a.dietitian_id = %s and a.weekday = %s
           order by a.start_time""",
        (day, day, dietitian_id, day.isoweekday()),
    ).fetchall()
    limit = datetime.now(TZ) + timedelta(hours=LEAD_HOURS)
    return [{"time": r["time"], "taken": r["taken"]} for r in rows if r["starts_at"] > limit]


@router.get("/{dietitian_id}/slots")
def slots(dietitian_id: str, day: date = Query(...), _=Depends(current_user), conn=Depends(get_conn)):
    return day_slots(conn, dietitian_id, day)
