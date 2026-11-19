"""Génération du PDF « compte rendu » remis à la patiente (fpdf2, polices PDF de base)."""

from fpdf import FPDF


def _t(s: str) -> str:
    # Les polices de base du PDF ne gèrent que le latin-1 : on remplace le reste.
    s = s.replace("œ", "oe").replace("Œ", "OE").replace("’", "'").replace("–", "-").replace("—", "-").replace("−", "-")
    return s.encode("latin-1", "replace").decode("latin-1")


def report_pdf(*, patient: str, dietitian: str, session_no: int, held_on: str, summary: str,
               goals: list[dict], plan: list[dict], labels: list[str], days: list[str]) -> bytes:
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    pdf.set_font("Helvetica", "B", 18)
    pdf.cell(0, 10, _t(f"Tchihali - Compte rendu de la seance {session_no}"), new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 11)
    pdf.cell(0, 7, _t(f"{patient} - {held_on} - {dietitian}"), new_x="LMARGIN", new_y="NEXT")
    pdf.ln(4)
    pdf.set_font("Helvetica", "B", 13)
    pdf.cell(0, 8, "Ce qu'il faut retenir", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 11)
    pdf.multi_cell(0, 6, _t(summary or "-"), new_x="LMARGIN", new_y="NEXT")
    pdf.ln(3)
    if goals:
        pdf.set_font("Helvetica", "B", 13)
        pdf.cell(0, 8, "Objectifs", new_x="LMARGIN", new_y="NEXT")
        pdf.set_font("Helvetica", "", 11)
        for g in goals:
            pdf.multi_cell(0, 6, _t(f"- {g.get('text', '')}"), new_x="LMARGIN", new_y="NEXT")
        pdf.ln(3)
    if any(m.get("text") for d in plan for m in d.get("meals", [])):
        pdf.set_font("Helvetica", "B", 13)
        pdf.cell(0, 8, "Plan alimentaire", new_x="LMARGIN", new_y="NEXT")
        for i, d in enumerate(plan[:7]):
            meals = [m for m in d.get("meals", []) if m.get("text")]
            if not meals:
                continue
            pdf.set_font("Helvetica", "B", 11)
            pdf.cell(0, 7, _t(days[i]), new_x="LMARGIN", new_y="NEXT")
            pdf.set_font("Helvetica", "", 10)
            for j, m in enumerate(d.get("meals", [])):
                if m.get("text"):
                    label = labels[j] if j < len(labels) else ""
                    pdf.multi_cell(0, 5, _t(f"{label} : {m['text']} ({m.get('kcal', 0)} kcal)"), new_x="LMARGIN", new_y="NEXT")
    return bytes(pdf.output())
